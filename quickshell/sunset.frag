#version 300 es
precision mediump float;

in vec2 v_texcoord;
layout(location = 0) out vec4 fragColor;
uniform sampler2D tex;

void main() {
    vec4 pixel = texture(tex, v_texcoord);
    // The former #228e5835 overlay, applied once to the completed screen.
    fragColor = vec4(mix(pixel.rgb, vec3(142.0, 88.0, 53.0) / 255.0, 34.0 / 255.0), pixel.a);
}
