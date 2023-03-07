shader_type canvas_item;

void fragment() {
    COLOR = texture(TEXTURE, UV); // Get pixel color from the image texture
    float grey = .21 * COLOR.r + .71 * COLOR.g + .07 * COLOR.b;
    COLOR.rgb = vec3(grey); // Change the color value
}
	/*COLOR = texture(TEXTURE, UV);
	vec4 curr_col = texture(TEXTURE, UV);
	if (curr_col == vec4(166.0/255.0, 166.0/255.0, 166.0/255.0, 1)) {
		COLOR == vec4(0.0/255.0, 77.0/255.0, 255.0/255.0, 1);
	} else {
		COLOR = curr_col;
	}
}*/