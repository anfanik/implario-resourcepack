#version 150

#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:projection.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV2;

uniform sampler2D Sampler2;

out float sphericalVertexDistance;
out float cylindricalVertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;

vec3 glyphiumAnchor(vec3 position) {
    if (ProjMat[3][0] != -1.0 || position.x < 8192.0) return position;
    vec2 screen = ceil(2.0 / abs(vec2(ProjMat[0][0], ProjMat[1][1])) - 0.01);
    float id = round(position.x / 16384.0);
    int anchor = int(id) - 1;
    float offset = position.x - id * 16384.0 - floor(screen.x / 2.0);
    return vec3(
        floor(float(anchor % 3) * screen.x / 2.0) + offset,
        floor(float(anchor / 3) * (screen.y - 128.0) / 2.0) + position.y - 3.0,
        position.z
    );
}

void main() {
    gl_Position = ProjMat * ModelViewMat * vec4(glyphiumAnchor(Position), 1.0);

    sphericalVertexDistance = fog_spherical_distance(Position);
    cylindricalVertexDistance = fog_cylindrical_distance(Position);
    vertexColor = Color * texelFetch(Sampler2, UV2 / 16, 0);
    texCoord0 = UV0;
}
