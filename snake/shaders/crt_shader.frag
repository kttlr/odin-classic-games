#version 330

// Input vertex attributes (from vertex shader)
in vec2 fragTexCoord;
in vec4 fragColor;

// Output fragment color
out vec4 finalColor;

// Uniforms
uniform sampler2D pixel_texture;
uniform vec2 screen_size;
uniform sampler2D texture0;  // This is the main texture in raylib

void main()
{
    // Apply the CRT effect
    vec2 uv = fragTexCoord * screen_size;
    uv -= floor(uv);
    vec4 crt_overlay = texture(pixel_texture, uv);
    vec4 base_texture = texture(texture0, fragTexCoord);

    finalColor.rgb = crt_overlay.rgb * base_texture.rgb * base_texture.a;
    finalColor.a = 1.0;
}
