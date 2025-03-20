shader_type canvas_item;
uniform vec4 outline_color : source_color = vec4(1.0, 0.84, 0.0, 1.0);
uniform float outline_width : hint_range(0, 4) = 1.0;
uniform bool outline_enabled = true;

void fragment() {
    vec4 sprite_color = texture(TEXTURE, UV);
    
    if (outline_enabled && sprite_color.a <= 0.01) {
        vec2 tex_size = vec2(textureSize(TEXTURE, 0));
        vec2 pixel_size = 1.0 / tex_size;
        
        float found_edge = 0.0;
        
        float distances[3] = float[](1.0, min(outline_width, 2.0), outline_width);
        
        for (int d = 0; d < 3 && found_edge < 0.01; d++) {
            float dist = distances[d];
            if (dist <= 0.0) continue;
            
            found_edge += texture(TEXTURE, UV + vec2(0.0, dist * pixel_size.y)).a;
            found_edge += texture(TEXTURE, UV + vec2(dist * pixel_size.x, 0.0)).a;
            found_edge += texture(TEXTURE, UV + vec2(0.0, -dist * pixel_size.y)).a;
            found_edge += texture(TEXTURE, UV + vec2(-dist * pixel_size.x, 0.0)).a;
            
            float diag = dist * 0.7071;
            found_edge += texture(TEXTURE, UV + vec2(diag * pixel_size.x, diag * pixel_size.y)).a;
            found_edge += texture(TEXTURE, UV + vec2(diag * pixel_size.x, -diag * pixel_size.y)).a;
            found_edge += texture(TEXTURE, UV + vec2(-diag * pixel_size.x, diag * pixel_size.y)).a;
            found_edge += texture(TEXTURE, UV + vec2(-diag * pixel_size.x, -diag * pixel_size.y)).a;
        }
        
        if (found_edge > 0.01) {
            sprite_color = outline_color;
        }
    }
    
    COLOR = sprite_color;
}