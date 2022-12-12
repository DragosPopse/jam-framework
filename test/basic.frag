#version 330 core

in vec4 VertexColor;
out vec4 oFragColor;

uniform float uScalar;

void main() 
{
    oFragColor = VertexColor * uScalar;
}