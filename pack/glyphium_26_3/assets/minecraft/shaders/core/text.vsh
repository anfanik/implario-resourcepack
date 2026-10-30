#version 330
#extension GL_ARB_separate_shader_objects : require

#if !defined(IS_GUI) && !defined(IS_SEE_THROUGH)
#include <minecraft:fog.glsl>
#include <minecraft:sample_lightmap.glsl>
#endif

#include <minecraft:dynamictransforms.glsl>
#include <minecraft:projection.glsl>

layout(location = 0) in vec3 Position;
layout(location = 1) in vec4 Color;
layout(location = 2) in vec2 UV0;
#if !defined(IS_GUI) && !defined(IS_SEE_THROUGH)
layout(location = 3) in ivec2 UV2;
#endif

#if !defined(IS_GUI) && !defined(IS_SEE_THROUGH)
uniform sampler2D Sampler2;
layout(location = 0) out float sphericalVertexDistance;
layout(location = 1) out float cylindricalVertexDistance;
#endif

layout(location = 2) out vec4 vertexColor;
layout(location = 3) out vec2 texCoord0;

vec3 glyphiumAnchor(vec3 position) {
    if (ProjMat[3][0] != -1.0 || position.x < 8192.0) return position;
    vec2 screen = ceil(2.0 / abs(vec2(ProjMat[0][0], ProjMat[1][1])) - 0.01);
    float id = round(position.x / 16384.0);
    int anchor = int(id) - 1;
    float offset = position.x - id * 16384.0 - floor(screen.x / 2.0);
    return vec3(
        floor(float(anchor % 3) * screen.x / 2.0) + offset,
        floor(float(anchor / 3) * (screen.y - 56.0) / 2.0) + position.y - 3.0,
        position.z
    );
}

void main() {
    gl_Position = ProjMat * ModelViewMat * vec4(glyphiumAnchor(Position), 1.0);

#if !defined(IS_GUI) && !defined(IS_SEE_THROUGH)
    sphericalVertexDistance = fog_spherical_distance(Position);
    cylindricalVertexDistance = fog_cylindrical_distance(Position);
    vertexColor = Color * sample_lightmap(Sampler2, UV2);
#else
    vertexColor = Color;
#endif
    texCoord0 = UV0;
}
