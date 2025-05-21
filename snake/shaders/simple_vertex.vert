#version 330

// Input vertex attributes
in vec3 vertexPosition;
in vec2 vertexTexCoord;
in vec4 vertexColor;

// Output vertex attributes (to fragment shader)
out vec2 fragTexCoord;
out vec4 fragColor;

// Uniform inputs
uniform mat4 mvp;

void main()
{
    // Pass texture coordinates and color to fragment shader
    fragTexCoord = vertexTexCoord;
    fragColor = vertexColor;
    
    // Calculate final vertex position
    gl_Position = mvp*vec4(vertexPosition, 1.0);
}