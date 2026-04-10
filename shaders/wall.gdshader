shader_type canvas_item;

uniform sampler2D mask;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    vec4 m = texture(mask, UV);

    if (m.a < 0.1) {       discard;
    }

    COLOR = tex;
}