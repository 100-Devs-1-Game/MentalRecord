shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(1.0, 0.0, 0.0, 1);
uniform float outline_thickness = 3.0;
uniform bool show_outline = false;

void fragment() {
    vec4 base_color = texture(TEXTURE, UV);
    COLOR = base_color;

    if (show_outline) {
        // This is a basic outline and might need refinement for complex shapes
        // Check neighboring pixels' alpha to detect edges
        bool is_edge = false;
        for (float x = -outline_thickness; x <= outline_thickness; x += 1.0) {
            for (float y = -outline_thickness; y <= outline_thickness; y += 1.0) {
                if (texture(TEXTURE, UV + vec2(x, y) * TEXTURE_PIXEL_SIZE).a > 0.9 && base_color.a < 0.5) {
                    is_edge = true;
                    break;
                }
            }
            if (is_edge) break;
        }

        if (is_edge) {
            COLOR = outline_color;
        }
    }
}