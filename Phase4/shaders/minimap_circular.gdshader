shader_type canvas_item;

uniform vec4 border_color : source_color = vec4(0.46, 0.82, 1.0, 1.0);
uniform vec4 inner_border_color : source_color = vec4(0.12, 0.28, 0.45, 0.85);
uniform float border_thickness : hint_range(0.01, 0.1) = 0.034;
uniform float contrast : hint_range(0.5, 3.0) = 1.35;
uniform float brightness : hint_range(-0.5, 0.5) = -0.04;
uniform float tactical_tint : hint_range(0.0, 1.0) = 0.70;

void fragment() {
	vec2 center = vec2(0.5, 0.5);
	float dist = distance(UV, center);
	
	if (dist > 0.5) {
		discard;
	}
	
	vec4 tex = texture(TEXTURE, UV);
	
	// Convert to high-contrast tactical map (dark walls, lighter paths like reference image)
	float luma = dot(tex.rgb, vec3(0.299, 0.587, 0.114));
	float contrasted = clamp((luma - 0.48) * contrast + 0.5 + brightness, 0.0, 1.0);
	
	vec3 dark_wall = vec3(0.09, 0.10, 0.12);
	vec3 light_path = vec3(0.60, 0.63, 0.67);
	vec3 tactical_tone = mix(dark_wall, light_path, contrasted);
	
	// Blend slight original terrain color with tactical monochrome
	vec3 map_col = mix(tex.rgb * 1.05, tactical_tone, tactical_tint);
	
	// Vignette for depth
	float vig = 1.0 - smoothstep(0.38, 0.50, dist) * 0.42;
	map_col *= vig;
	
	// Sky blue / cyan outer rim
	if (dist >= (0.5 - border_thickness) && dist <= 0.5) {
		COLOR = border_color;
	} else if (dist >= (0.5 - border_thickness - 0.015) && dist < (0.5 - border_thickness)) {
		COLOR = inner_border_color;
	} else {
		COLOR = vec4(map_col, 1.0);
	}
}
