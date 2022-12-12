package test 

import "core:fmt"
import "core:c"
import "core:runtime"
import "core:strings"
import intr "core:intrinsics"
import gl "vendor:OpenGL"
import smolarr "core:container/small_array"


ShaderProgram :: struct {
    shaders: smolarr.Small_Array(5, GLHandle),
    handle: GLHandle,
    uniforms: map[string]c.int,
}

NULL_PROGRAM :: ShaderProgram {}

make_program :: #force_inline proc() -> (result: ShaderProgram) {
    using result
    handle = gl.CreateProgram() 
    return
}

delete_program :: #force_inline proc(program: ShaderProgram) {
    if program.uniforms != nil {
        for k, v in program.uniforms {
            delete(k) // strings are dynamically allocated here
        }
        delete(program.uniforms)
    }
    
}

add_shader :: proc(using program: ^ShaderProgram, src: string, type: c.uint) -> GLHandle {
    shader: GLHandle = gl.CreateShader(type)
    csrc := strings.unsafe_string_to_cstring(src) // this might not be null terminated, but we provide the length anyway 
    length := cast(i32)len(src)
    gl.ShaderSource(shader, 1, &csrc, &length)
    gl.AttachShader(handle, shader)
    return shader
}

compile_shader :: proc(shader: GLHandle) -> (temp_info: string, ok: bool) {
    using fmt 
    gl.CompileShader(shader)
    
    success: c.int 
    log: [512]u8 
    
    gl.GetShaderiv(shader, gl.COMPILE_STATUS, &success)
    
    if success == 0 {
        logLength: c.int 
        gl.GetShaderInfoLog(shader, size_of(log), &logLength, &log[0])
        logstr := strings.string_from_ptr(&log[0], cast(int)logLength)
        return tprintf("%s", logstr), false
    }

    return temp_info, true
}

compile_shaders :: proc(using program: ^ShaderProgram) -> (temp_info: string, ok: bool) {
    s := smolarr.slice(&shaders)
    for shader in s {
        if temp_info, ok = compile_shader(shader); !ok {
            return
        }
    }
    return temp_info, true
}

link_program :: proc(using program: ^ShaderProgram, delete_shaders := true) -> (temp_info: string, ok: bool) {
    gl.LinkProgram(handle)
    defer {
        if delete_shaders {
            s := smolarr.slice(&shaders)
            for shader in s {
                gl.DeleteShader(shader)
            }
        }
    }

    success: c.int 
    log: [512]u8 
    gl.GetProgramiv(handle, gl.LINK_STATUS, &success)
    
    if success == 0 {
        logLength: c.int 
        gl.GetProgramInfoLog(handle, size_of(log), &logLength, &log[0])
        logstr := strings.string_from_ptr(&log[0], cast(int)logLength)
        return fmt.tprintf("%s", logstr), false
    }

    _init_program_uniforms(program)
    return temp_info, true
}

_init_program_uniforms :: proc(using program: ^ShaderProgram) {
    uniforms = make(type_of(uniforms))
    count: c.int 
    name: [64]u8
    length: c.int
    gl.GetProgramiv(handle, gl.ACTIVE_UNIFORMS, &count)
    for i in 0..<count {
        size: c.int 
        type: c.uint
        gl.GetActiveUniform(handle, cast(c.uint)i, size_of(name), &length, &size, &type, &name[0])
        key := strings.clone_from_bytes(name[:length])
        uniforms[key] = i
    }
}

bind_program :: #force_inline proc(using program: ShaderProgram) {
    gl.UseProgram(handle)
}

get_uniform_location :: #force_inline proc(using program: ShaderProgram, name: string) -> c.int {
    return uniforms[name] or_else -1
}

uniform_f32 :: #force_inline proc(using program: ShaderProgram, name: string, val: f32) {
    location := get_uniform_location(program, name) 
    gl.Uniform1f(location, val)
}

uniform_int :: #force_inline proc(using program: ShaderProgram, name: string, #any_int val: int) {
    location := get_uniform_location(program, name) 
    gl.Uniform1i(location, cast(c.int)val)
}

uniform_bool :: #force_inline proc(using program: ShaderProgram, name: string, val: bool) {
    location := get_uniform_location(program, name) 
    gl.Uniform1i(location, cast(c.int)val)
}
