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


Transform :: struct {
    using pos: Vec3f,
    rot: Vec3f,
    scale: Vec3f,
}

IdentityTransform :: Transform {
    pos = {0, 0, 0},
    rot = {0, 0, 0},
    scale = {1, 1, 1},
}

transform_to_mat4f :: proc(t: Transform) -> (m: Mat4f) {
    m = Mat4f(1)
    m *= alg.matrix4_translate(t.pos)
    m *= alg.matrix4_from_euler_angles_xyz_f32(t.rot.x, t.rot.y, t.rot.z)
    m *= alg.matrix4_scale(t.scale)
    return
}