shader_type canvas_item;

uniform sampler2D palette_texture : filter_nearest;
uniform int idx : hint_range(0, 100) = 0; 
uniform float opacity : hint_range(0.0, 1.0) = 1.0;

void fragment() {
    vec4 rgba = texture(TEXTURE, UV);
	
    if (rgba.a < 0.001) {
        discard;
    }

    ivec2 size = textureSize(palette_texture, 0);
    float color_count = float(size.x);
    float palette_count = float(size.y);

    float precision = 0.001;
    vec4 final_color = rgba;

    for (int i = 0; i < size.x; i++) {
        float x_uv = (float(i) + 0.5) / color_count;

        vec4 base_color = texture(palette_texture, vec2(x_uv, 0.5 / palette_count));

        if (distance(rgba.rgb, base_color.rgb) < precision) {
            float target_row = clamp(float(idx), 0.0, palette_count - 1.0);
            float y_uv = (target_row + 0.5) / palette_count;
            
            final_color = texture(palette_texture, vec2(x_uv, y_uv));
            break;
        }
    }

    COLOR = vec4(final_color.rgb, final_color.a * rgba.a * opacity);
}