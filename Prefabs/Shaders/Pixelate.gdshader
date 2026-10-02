shader_type canvas_item;

uniform sampler2D screenTexture : hint_screen_texture;
uniform vec2 targetResolution;

void fragment()
{
	vec2 uv = floor(SCREEN_UV * targetResolution) / targetResolution;
	COLOR = texture(screenTexture, uv);
}
