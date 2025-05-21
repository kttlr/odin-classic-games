#version 330

// Input vertex attributes (from vertex shader)
in vec2 fragTexCoord;
in vec4 fragColor;

// Output fragment color
out vec4 finalColor;

// Uniforms
uniform sampler2D texture0;
uniform float iTime;  // Time for animation

void main()
{
    // Get the base color
    vec4 texelColor = texture(texture0, fragTexCoord);
    
    // Only apply effect to non-transparent pixels (the snake)
    if (texelColor.a > 0.0) {
        // Create a wave effect that moves along the snake
        float wave = sin(fragTexCoord.x * 20.0 + iTime * 3.0) * sin(fragTexCoord.y * 20.0 + iTime * 2.0);
        
        // Create a pulsing color effect
        vec3 baseColor = vec3(0.0, 0.8, 0.2);  // Base green color
        vec3 pulseColor = vec3(0.2, 1.0, 0.4); // Brighter green for pulse
        
        // Mix between the two colors based on wave and time
        vec3 finalSnakeColor = mix(baseColor, pulseColor, 0.5 + 0.5 * wave);
        
        // Apply the effect
        finalColor = vec4(finalSnakeColor, texelColor.a);
    } else {
        // Pass through transparent pixels unchanged
        finalColor = texelColor;
    }
}