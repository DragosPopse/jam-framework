package test

import "core:fmt"
import "core:c"
import "core:runtime"
import "core:strings"
import intr "core:intrinsics"
import gl "vendor:OpenGL"
import smolarr "core:container/small_array"

GLHandle :: u32



VertexArray :: struct {
    handle: GLHandle,
    n: c.uint,
}

NULL_VAO :: VertexArray{}

make_vertex_array :: #force_inline proc() -> (result: VertexArray) {
    using result 
    gl.GenVertexArrays(1, &handle)
    return
}

make_vertex_buffer :: #force_inline proc(data: []$T, usage: c.uint) -> (vbo: GLHandle) {
    gl.GenBuffers(1, &vbo)

    gl.BindBuffer(gl.ARRAY_BUFFER, vbo) 
    gl.BufferData(gl.ARRAY_BUFFER, size_of(data[0]) * len(data), &data[0], usage)

    gl.BindBuffer(gl.ARRAY_BUFFER, 0)
    return vbo
}

make_index_buffer :: #force_inline proc(data: []c.uint, usage: c.uint) -> (ebo: GLHandle) {
    gl.GenBuffers(1, &ebo) 
    gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, ebo)
    gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, len(data) * size_of(c.uint), &data[0], usage)
    return
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


bind_vertex_array :: #force_inline proc(vao: VertexArray) {
    gl.BindVertexArray(vao.handle)
}

