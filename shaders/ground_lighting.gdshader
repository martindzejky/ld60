shader_type spatial;
render_mode cull_disabled, specular_disabled;

uniform sampler2D ground_texture : source_color;

void fragment() {
  ALBEDO = texture(ground_texture, UV).rgb * COLOR.rgb;
}

void light() {
  // Godot supplies attenuation for each light, including its shadows.
  float lit = step(0.001, ATTENUATION);
  DIFFUSE_LIGHT += lit * LIGHT_COLOR / PI;
}
