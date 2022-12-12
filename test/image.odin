package test 

import "core:fmt"
import "core:c"
import "core:runtime"
import "core:strings"
import "core:slice"
import intr "core:intrinsics"
import gl "vendor:OpenGL"
import stbi "vendor:stb/image"

Image :: struct {
    pixels: []Vec4bt,
    size: [2]uint,
}

load_image_from_file :: proc(path: string, allocator := context.allocator) -> (img: Image, ok: bool) {
    stbi.set_flip_vertically_on_load(1)
    width, height, channels: c.int
    cpath := strings.clone_to_cstring(path, context.temp_allocator)
    data := stbi.load(cpath, &width, &height, &channels, 4)
    defer if data != nil do stbi.image_free(data)
    if data == nil {
        return img, false
    }
    sliceData := slice.from_ptr(data, int(width * height * channels));
    reinterpret := slice.reinterpret([]Vec4bt, sliceData)
    img.pixels = slice.clone(reinterpret, allocator)
    img.size.x = cast(uint)width
    img.size.y = cast(uint)height
    return img, true
}

delete_image :: proc(img: Image) {
    delete(img.pixels)
}

get_pixel_indices :: #force_inline proc(using img: Image, x, y: uint) -> Vec4bt {
    return pixels[x * size.x + y]
}

get_pixel_position :: #force_inline proc(using img: Image, position: [2]uint) -> Vec4bt {
    return get_pixel_indices(img, position.x, position.y)
}

set_pixel_indices :: #force_inline proc(using img: Image, x, y: uint, val: Vec4bt) {
    pixels[x * size.x + y] = val
}

set_pixel_position :: #force_inline proc(using img: Image, position: [2]uint, val: Vec4bt) {
    set_pixel_indices(img, position.x, position.y, val)
}

get_pixel :: proc {
    get_pixel_indices,
    get_pixel_position,
}

set_pixel :: proc {
    set_pixel_indices,
    set_pixel_position,
}

