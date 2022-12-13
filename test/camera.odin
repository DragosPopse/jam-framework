package test

import "core:fmt"
import "core:c"
import "core:runtime"
import "core:strings"
import intr "core:intrinsics"
import smolarr "core:container/small_array"

import glm "core:math/linalg/glsl"
import math "core:math"
import alg "core:math/linalg"


Camera :: struct {
    transform: Transform,
    projection: Mat4f,
}

@(require_results)
camera_to_mat4f :: proc(c: Camera) -> (transform: Mat4f, projection: Mat4f) {
    transform = transform_to_mat4f(c.transform)
    projection = c.projection
    return
}