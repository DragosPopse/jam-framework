package test

import "core:fmt"
import "core:c"
import "core:runtime"
import "core:strings"
import intr "core:intrinsics"
import gl "vendor:OpenGL"
import smolarr "core:container/small_array"

GLHandle :: u32

ShaderProgram :: struct {
    shaders: smolarr.Small_Array(5, GLHandle),
    handle: GLHandle,
}

VertexArray :: struct {
    handle: GLHandle,
    n: c.uint,
}


make_vertex_array :: proc() -> (result: VertexArray) {
    using result 
    gl.GenVertexArrays(1, &handle)
    return
}

make_vertex_buffer :: proc(data: []$T, usage: c.uint) -> (vbo: GLHandle) {
    gl.GenBuffers(1, &vbo)

    gl.BindBuffer(gl.ARRAY_BUFFER, vbo) 
    gl.BufferData(gl.ARRAY_BUFFER, size_of(data[0]) * len(data), &data[0], usage)

    gl.BindBuffer(gl.ARRAY_BUFFER, 0)
    return vbo
}

va_add_buffer :: proc(vao: ^VertexArray, data: []$T, usage: c.uint) {
    bind_vertex_array(vao^)
    vbo := make_vertex_buffer(data, usage)
    gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
    stride := cast(c.int)size_of(T)
    tinfo := runtime.type_info_base(type_info_of(T))

    record := tinfo.variant.(runtime.Type_Info_Struct)

    for name, i in record.names {
        type := record.types[i] 
        offset := record.offsets[i] 
        #partial switch x in type.variant {
            case: {
                assert(false, "Unsupported type found")
            }

            case runtime.Type_Info_Array: {
                gl.VertexAttribPointer(vao.n, cast(c.int)x.count, gl.FLOAT, false, stride, offset)
                gl.EnableVertexAttribArray(vao.n)
                vao.n += 1
            }

            case runtime.Type_Info_Float: {
                gl.VertexAttribPointer(vao.n, 1, gl.FLOAT, false, stride, offset)
                gl.EnableVertexAttribArray(vao.n)
                vao.n += 1
            }
        }
    }
}

create_program :: proc() -> (result: ShaderProgram) {
    using result
    handle = gl.CreateProgram() 
    return
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

    return temp_info, true
}

bind_program :: #force_inline proc(using program: ShaderProgram) {
    gl.UseProgram(handle)
}

bind_vertex_array :: proc(vao: VertexArray) {
    gl.BindVertexArray(vao.handle)
}