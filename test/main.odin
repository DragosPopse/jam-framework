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

import "core:math"
import alg "core:math/linalg"
import glm "core:math/linalg/glsl"


OGL_MAJOR :: 3
OGL_MINOR :: 3
OGL_PROFILE :: cast(c.int)sdl.GLprofile.CORE

Vec3f :: [3]f32 // a distinct will break the parser, and the reflection too
Vec2f :: [2]f32
Vec4f :: [4]f32
Vec4bt :: [4]byte

Mat4f :: matrix[4, 4]f32
Mat3f :: matrix[3, 3]f32

Vertex :: struct {
    using pos: Vec3f,
    col: Vec4f,
    tex: Vec2f,
}

BACKEND :: #config(JAM_BACKEND, "Undefined")


main :: proc() {
    using fmt
    
    sdl.GL_SetAttribute(.CONTEXT_MAJOR_VERSION, OGL_MAJOR)
    sdl.GL_SetAttribute(.CONTEXT_MINOR_VERSION, OGL_MINOR)
    sdl.GL_SetAttribute(.CONTEXT_PROFILE_MASK, OGL_PROFILE)
    window := sdl.CreateWindow("It's a marmalade", sdl.WINDOWPOS_CENTERED, sdl.WINDOWPOS_CENTERED, 800, 600, sdl.WINDOW_OPENGL)
    glcontext := sdl.GL_CreateContext(window)
    gl.load_up_to(OGL_MAJOR, OGL_MINOR, sdl.gl_set_proc_address)
    gl.ClearColor(0.012, 0.533, 0.988, 1.0)

    color := Vec4f {0.4, 0.7, 0.8, 1.0}
    when BACKEND == "OpenGL" {
        fmt.printf("Found opengl\n")
    } else {
        
    }
    vertices := [?]Vertex {
        {
            pos = {0.5, 0.5, 0.0},
            col = color / 2,
            tex = {1, 1},
        },
        {
            pos = {0.5, -0.5, 0.0},
            col = color / 3,
            tex = {1, 0},
        },
        {
            pos = {-0.5,  -0.5, 0.0},
            col = color / 4,
            tex = {0, 0},
        },
        {
            pos = {-0.5,  0.5, 0.0},
            col = color,
            tex = {0, 1},
        },
    }

    indices := [?]c.uint {
        0, 1, 3, 
        1, 2, 3,
    }

    vao := make_vertex_array() 
    va_add_buffer(&vao, vertices[:], gl.STATIC_DRAW)
    ebo := make_index_buffer(indices[:], gl.STATIC_DRAW)
    vertSrc := #load("basic.vert", string)
    fragSrc := #load("basic.frag", string)

    shader := make_program() 
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

    image, imageLoaded := load_image_from_file(`D:\dev\jam\assets\textures\coin.png`)
    if !imageLoaded {
        fmt.printf("Failed to load image\n")
        return
    }
    defer if imageLoaded do delete_image(image)
    for pixel in &image.pixels {
        pixel.r = 255
    }
    texture := load_texture_from_image(image)
    
 
    camera: Camera 
  
    rotation := f32(0)
    //gl.PolygonMode(gl.FRONT_AND_BACK, gl.LINE)
    running := true
    scalar: f32 = 0
    for running {
        event: sdl.Event 
        for sdl.PollEvent(&event) {
            #partial switch event.type {
                case .QUIT: {
                    running = false 
                }
            }
        }
        rotation += 5
        //model := Mat4f(1)
        //model *= alg.matrix4_translate(Vec3f{0.2, 0.2, 0}) // This only works if we don't have goofy distincts
        //model *= alg.matrix4_rotate(math.to_radians_f32(rotation), Vec3f{0, 0, 1})
        //model *= alg.matrix4_scale(Vec3f{1, 1, 1})
        model := IdentityTransform
        model.pos = {0.2, 0.2, 0}
        model.rot = {0, 0, math.to_radians_f32(rotation)}
        model.scale = {1, 1, 1}

        
        gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)
        bind_program(shader)
        scalar += 0.001 
        if scalar > 2 {
            scalar = 0
        }
        uniform_f32(shader, "uScalar", scalar)
        uniform_mat4f(shader, "uTransform", transform_to_mat4f(model))
        bind_texture(texture)
        gl.Enable(gl.BLEND)
        gl.BlendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA)
        gl.DrawElements(gl.TRIANGLES, 6, gl.UNSIGNED_INT, nil)
        sdl.GL_SwapWindow(window)
    }
}