shader_type spatial;
render_mode cull_disabled, specular_disabled, shadows_disabled;

uniform sampler2D sprite_texture : source_color;
uniform bool billboard = false;
uniform bool omnidirectional = false;

void vertex() {
  if (billboard) {
    MODELVIEW_MATRIX = VIEW_MATRIX * mat4(
      MAIN_CAM_INV_VIEW_MATRIX[0], MAIN_CAM_INV_VIEW_MATRIX[1],
      MAIN_CAM_INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
    MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
  }
}

void fragment() {
  vec4 color = texture(sprite_texture, UV) * COLOR;
  ALBEDO = color.rgb;
  ALPHA = color.a;
  ALPHA_SCISSOR_THRESHOLD = 0.5;
}

void light() {
  float lit = step(0.001, ATTENUATION);
  float facing = omnidirectional ? 1.0 : max(dot(NORMAL, LIGHT), 0.0);
  DIFFUSE_LIGHT += facing * lit * LIGHT_COLOR / PI;
}
