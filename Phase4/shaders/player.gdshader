shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	float gradient = abs(sin(UV.x * 20.0 + TIME * 3.0));
	vec4 temp_color = texture(TEXTURE, UV);
	COLOR = vec4(temp_color.r + gradient, temp_color.g, temp_color.b, temp_color.a);
}

void light() {
	// Called for every pixel for every light affecting the CanvasItem.
}
