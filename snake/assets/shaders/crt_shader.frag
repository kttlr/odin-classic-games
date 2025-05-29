#version 330

// Input vertex attributes (from vertex shader)
in vec2 fragTexCoord;
in vec4 fragColor;

// Output fragment color
out vec4 finalColor;

// Uniforms
uniform sampler2D texture0; // The main game texture
uniform vec2 screen_size; // Screen dimensions
uniform float iTime; // Time for animation effects

void main()
{
    // Get base texture color
    vec4 base_texture = texture(texture0, fragTexCoord);

    // CRT curvature effect
    vec2 uv = fragTexCoord * 2.0 - 1.0; // Convert to -1 to 1 range
    float distortion = 0.05; // Curvature amount

    // Apply barrel distortion
    float r2 = uv.x * uv.x + uv.y * uv.y;
    uv *= 1.0 + r2 * distortion;

    // Check if we're outside the screen after distortion
    bool outside = abs(uv.x) > 1.0 || abs(uv.y) > 1.0;

    if (outside) {
        finalColor = vec4(0.0, 0.0, 0.0, 1.0); // Black for outside areas
    } else {
        // Convert back to 0-1 range for texture lookup
        uv = (uv + 1.0) * 0.5;

        // Sample the texture with the distorted UVs
        vec4 texColor = texture(texture0, uv);

        // Apply RGB mask for aperture grille effect
        // float mask_intensity = 0.05;
        // float x_pos = fragTexCoord.x * screen_size.x;
        // float r_mask = 0.8 + mask_intensity * sin(x_pos * 3.14159 * 3.0 + 0.0);
        // float g_mask = 0.8 + mask_intensity * sin(x_pos * 3.14159 * 3.0 + 2.0944);
        // float b_mask = 0.8 + mask_intensity * sin(x_pos * 3.14159 * 3.0 + 4.1888);

        // Apply the color masks to create RGB grille
        // texColor.r *= r_mask;
        // texColor.g *= g_mask;
        // texColor.b *= b_mask;

        // Apply horizontal scanlines (separate from the vertical RGB mask)
        float scanline_intensity = 0.1;
        float scanline = sin(fragTexCoord.y * screen_size.y * 3.0) * scanline_intensity;
        texColor.rgb -= vec3(scanline);

        // Vignette effect (darker corners)
        float vignette = r2 * 0.05;
        texColor.rgb *= (1.0 - vignette);

        // Oscillating shift amount for both directions
        float shift_x = 0.0035 * sin(iTime * 1.0); // Left-right
        float shift_y = 0.0035 * cos(iTime * 1.2); // Up-down

        vec2 shift = vec2(shift_x, shift_y);

        // Sample texture with RGB offsets
        float red = texture(texture0, uv - shift).r;
        float green = texColor.g; // Assume texColor is sampled normally from texture0
        float blue = texture(texture0, uv + shift).b;

        // Apply flicker
        float flicker = 0.99 + 0.03 * sin(iTime * 2.0);

        // Final color with CRT effects
        finalColor = vec4(vec3(red, green, blue) * flicker, 1.0);
    }
}
