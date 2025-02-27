shader_type canvas_item;

uniform float vignette_intensity = 0.7;
uniform float vignette_opacity : hint_range(0.0, 1.0) = 0.5;
uniform vec4 vignette_rgb : source_color = vec4(0.75, 0.0, 0.0, 1.0);

void fragment() {
    // Get the distance from current pixel to the center
    vec2 uv = UV - 0.5;
    float dist = length(uv);
    
    // Create vignette effect (stronger at edges)
    float vignette = smoothstep(0.4, 0.75, dist);
    
    // Apply the vignette
    COLOR = vec4(vignette_rgb.rgb, vignette * vignette_opacity);
}
