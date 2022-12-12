package test 

import "core:fmt"
import "shared:lua"
import "shared:luaL"
import "shared:mani"
import "core:c"
import "core:runtime"
import "core:strings"
import intr "core:intrinsics"
import gl "vendor:OpenGL"
import sdl "vendor:sdl2"
import smolarr "core:container/small_array"


OGL_MAJOR :: 3
OGL_MINOR :: 3
OGL_PROFILE :: cast(c.int)sdl.GLprofile.CORE

Vec3f :: [3]f32 
Vec2f :: [2]f32 
Vec4f :: [4]f32

Vertex :: struct {
    using pos: Vec3f,
    col: Vec4f,
}


main :: proc() {
    using fmt

    sdl.GL_SetAttribute(.CONTEXT_MAJOR_VERSION, OGL_MAJOR)
    sdl.GL_SetAttribute(.CONTEXT_MINOR_VERSION, OGL_MINOR)
    sdl.GL_SetAttribute(.CONTEXT_PROFILE_MASK, OGL_PROFILE)
    window := sdl.CreateWindow("It's a marmalade", sdl.WINDOWPOS_CENTERED, sdl.WINDOWPOS_CENTERED, 600, 600, sdl.WINDOW_OPENGL)
    glcontext := sdl.GL_CreateContext(window)
    gl.load_up_to(OGL_MAJOR, OGL_MINOR, sdl.gl_set_proc_address)
    gl.ClearColor(0.4, 0.6, 0.3, 1.0)

    color := Vec4f {0.6, 0.3, 0.3, 1.0}

    vertices := [?]Vertex {
        {
            pos = {-0.5, -0.5, 0.0},
            col = color,
        },
        {
            pos = {0.5, -0.5, 0.0},
            col = color,
        },
        {
            pos = {0.0,  0.5, 0.0},
            col = color,
        },
    }

    vao := make_vertex_array() 
    va_add_buffer(&vao, vertices[:], gl.STATIC_DRAW)
    
    vertSrc := #load("basic.vert", string)
    fragSrc := #load("basic.frag", string)
    shader := create_program() 
    add_shader(&shader, vertSrc, gl.VERTEX_SHADER)
    add_shader(&shader, fragSrc, gl.FRAGMENT_SHADER)
    if info, ok := compile_shaders(&shader); !ok {
        fmt.printf("Compile Error: %s\n", info)
        return
    }

    if info, ok := link_program(&shader); !ok {
        fmt.printf("Link Error: %s\n", info)
        return
    }

    running := true 
    for running {
        event: sdl.Event 
        for sdl.PollEvent(&event) {
            #partial switch event.type {
                case .QUIT: {
                    running = false 
                }
            }
        }
        gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)
        bind_program(shader)
        
        gl.DrawArrays(gl.TRIANGLES, 0, 3)
        sdl.GL_SwapWindow(window)
    }
}