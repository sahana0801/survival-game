shader_type canvas_item;

uniform vec2 scroll1 = vec2(0.5, 0.5);
uniform vec2 scroll2 = vec2(0.3, 0.3);
uniform vec2 noiseScale1 = vec2(1.0, 1.0);
uniform vec2 noiseScale2 = vec2(1.0, 1.0);
uniform sampler2D TONE_MAPPING;
uniform sampler2D NOISE_PATTERN;
uniform float blur : hint_range(0.0, 7.0) = 3.0;
uniform float base_intensity : hint_range(0.0, 0.5) = 0.1;
uniform float intensity_factor : hint_range(0.0, 5.0) = 1.5;
//uniform float pattern_intensity1 : hint_range(0.0, 5.0) = 1.5;
//uniform float pattern_intensity2 : hint_range(0.0, 5.0) = 2.5;

void fragment() {
	float tex_alpha = textureLod(TEXTURE, UV, blur).a;
	float pattern_intensity1 = texture(NOISE_PATTERN, UV * noiseScale1 + TIME * scroll1).r;
	float pattern_intensity2 = texture(NOISE_PATTERN, UV * noiseScale2 + TIME * scroll2).r;
	float intensity = tex_alpha * intensity_factor * (pattern_intensity1 * pattern_intensity2 + base_intensity);
	COLOR = texture(TONE_MAPPING, vec2(intensity));
}

