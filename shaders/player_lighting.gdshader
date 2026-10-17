shader_type spatial;
render_mode cull_disabled, specular_disabled;

uniform sampler2D sprite_texture : source_color;

void fragment() {
  vec4 color = texture(sprite_texture, UV) * COLOR;
  ALBEDO = color.rgb;
  ALPHA = color.a;
  ALPHA_SCISSOR_THRESHOLD = 0.5;
}

void light() {
  float lit = step(0.001, ATTENUATION);
  DIFFUSE_LIGHT += lit * LIGHT_COLOR / PI;
}
