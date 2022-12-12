#version 330 core

in vec4 VertexColor;
out vec4 oFragColor;

void main() 
{
    oFragColor = VertexColor;
}