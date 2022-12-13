#version 330 core

layout (location = 0) in vec3 aPos;
layout (location = 1) in vec4 aCol;
layout (location = 2) in vec2 aTex;

out vec4 VertexColor;
out vec2 TexCoord;

uniform mat4 uTransform;

void main() 
{
    gl_Position =  uTransform * vec4(aPos.xyz, 1.0);
    VertexColor = aCol;
    TexCoord = aTex;
}