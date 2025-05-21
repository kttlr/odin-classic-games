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
    
    // Only process non-transparent pixels (the food)
    if (texelColor.a > 0.0) {
        // Create a bright pulsing effect for food
        float pulse = 0.7 + 0.3 * sin(iTime * 4.0);
        
        // Create a color-shifting effect
        vec3 baseColor = vec3(1.0, 0.0, 0.0);  // Red base
        vec3 shiftColor = vec3(1.0, 0.6, 0.0); // Orange-yellow shift
        
        // Mix colors based on a separate sine wave
        float colorMix = 0.5 + 0.5 * sin(iTime * 2.5);
        vec3 foodColor = mix(baseColor, shiftColor, colorMix);
        
        // Apply pulse intensity and color to the food
        finalColor = vec4(foodColor * pulse, texelColor.a);
        
        // Add a subtle glow around edges
        float edgeDistance = min(min(fragTexCoord.x, 1.0-fragTexCoord.x), 
                               min(fragTexCoord.y, 1.0-fragTexCoord.y));
        float edgeGlow = 0.2 * max(0.0, 1.0 - edgeDistance * 10.0) * pulse;
        
        // Brighten the result with the edge glow
        finalColor.rgb += vec3(edgeGlow);
    } else {
        // Pass through transparent pixels unchanged
        finalColor = texelColor;
    }
}