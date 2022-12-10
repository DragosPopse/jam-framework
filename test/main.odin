package test 

import "core:fmt"
import "shared:lua"
import "shared:luaL"
import "shared:mani"
import "core:c"
import gl "vendor:OpenGL"
import sdl "vendor:sdl2"

OGL_MAJOR :: 3
OGL_MINOR :: 3
OGL_PROFILE :: cast(c.int)sdl.GLprofile.CORE

main :: proc() {
    using fmt

    sdl.GL_SetAttribute(.CONTEXT_MAJOR_VERSION, OGL_MAJOR)
    sdl.GL_SetAttribute(.CONTEXT_MINOR_VERSION, OGL_MINOR)
    sdl.GL_SetAttribute(.CONTEXT_PROFILE_MASK, OGL_PROFILE)
    window := sdl.CreateWindow("It's a marmalade", sdl.WINDOWPOS_CENTERED, sdl.WINDOWPOS_CENTERED, 600, 600, sdl.WINDOW_OPENGL)
    glcontext := sdl.GL_CreateContext(window)
    gl.load_up_to(OGL_MAJOR, OGL_MINOR, sdl.gl_set_proc_address)

    gl.ClearColor(0.4, 0.6, 0.3, 1.0)

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
        sdl.GL_SwapWindow(window)
    }
}