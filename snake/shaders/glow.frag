#version 330

// Input vertex attributes (from vertex shader)
in vec2 fragTexCoord;
in vec4 fragColor;

// Output fragment color
out vec4 finalColor;

// Uniforms
uniform sampler2D texture0;
uniform float iTime; // Time for animation

void main()
{
    // Get the base texture color
    vec4 texelColor = texture(texture0, fragTexCoord);

    // Create a pulsing glow effect
    float glow = 0.6 + 0.4 * sin(iTime * 2.0);

    // Apply the glow only to non-black pixels (i.e., the snake and food)
    if (length(texelColor.rgb) > 0.1) {
        // Enhanced color with pulsing glow
        vec3 colorShift = vec3(1.0, 0.5 + 0.5 * sin(iTime * 2.0), 0.0);
        finalColor = texelColor * vec4(colorShift, 1.0);
    } else {
        // Keep background as is
        finalColor = texelColor;
    }
}
