package test 

import "core:fmt"
import "shared:lua"
import "shared:luaL"
import "shared:mani"
import "core:c"
import gl "vendor:OpenGL"
import sdl "vendor:sdl2"


main :: proc() {
    using fmt
    window := sdl.CreateWindow("It's a marmalade", sdl.WINDOWPOS_CENTERED, sdl.WINDOWPOS_CENTERED, 600, 600, sdl.WINDOW_OPENGL)
    glcontext := sdl.GL_CreateContext(window)

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

        sdl.GL_SwapWindow(window)
    }
}