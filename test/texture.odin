package test

import "core:fmt"
import "core:c"
import "core:runtime"
import "core:strings"
import "core:slice"
import intr "core:intrinsics"
import gl "vendor:OpenGL"

Texture :: struct {
    handle: GLHandle,
    size: [2]uint,
}

NULL_TEX :: Texture{}

load_texture_from_image :: proc(img: Image) -> (tex: Texture) {
    tex.size = img.size 
    gl.GenTextures(1, &tex.handle)
    gl.BindTexture(gl.TEXTURE_2D, tex.handle)
    gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGBA, cast(c.int)tex.size.x, cast(c.int)tex.size.y, 0, gl.RGBA, gl.UNSIGNED_BYTE, &img.pixels[0])
    gl.GenerateMipmap(gl.TEXTURE_2D)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT) // this shouldn't be here I believe
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_NEAREST)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST)
    return
}

delete_texture :: #force_inline proc(tex: Texture) {
    h := tex.handle // small hack to accept read-only Texture
    gl.DeleteTextures(1, &h)
}

bind_texture :: #force_inline proc(tex: Texture) {
    gl.BindTexture(gl.TEXTURE_2D, tex.handle)
}