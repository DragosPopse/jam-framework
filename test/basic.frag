#version 330 core

in vec4 VertexColor;
in vec2 TexCoord;
out vec4 oFragColor;

uniform float uScalar;
uniform sampler2D uTexture;

void main() 
{
    oFragColor = texture(uTexture, TexCoord) * VertexColor * uScalar;
}