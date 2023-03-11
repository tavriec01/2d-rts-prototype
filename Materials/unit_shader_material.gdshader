shader_type canvas_item;

uniform vec4 REPLACE_COLOR : source_color;
uniform vec4 FACTION_COLOR : source_color;

void fragment() {
	vec4 curr_color = texture(TEXTURE, UV);
	if (curr_color == REPLACE_COLOR){
		COLOR = FACTION_COLOR;
	} else {
		COLOR = curr_color;
	}
}
