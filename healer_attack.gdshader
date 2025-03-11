shader_type canvas_item;

void fragment() {
    float dist = distance(UV, vec2(0.5));
    if (dist > 0.5) {
        COLOR.a = 0.0;
    } else {
        // Optional: fade the edges
        COLOR.a = COLOR.a * smoothstep(0.5, 0.4, dist);
    }
}
