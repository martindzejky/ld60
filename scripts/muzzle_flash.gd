class_name MuzzleFlash
extends Node3D

@export var beam: Sprite3D
@export var light: OmniLight3D
@export var duration: float = 0.1
@export var width: float = 0.035


func play(start: Vector3, end: Vector3) -> void:
  global_position = start
  var direction := start.direction_to(end)
  var camera := get_viewport().get_camera_3d()
  var side := camera.global_basis.z.cross(direction).normalized()
  beam.global_position = (start + end) * 0.5
  beam.global_basis = Basis(direction, side, direction.cross(side)).scaled_local(
    Vector3(start.distance_to(end), width, 1.0)
  )
  var tween := create_tween().set_parallel(true)
  tween.tween_property(light, 'light_energy', 0.0, duration)
  tween.tween_property(beam, 'modulate:a', 0.0, duration)
  tween.chain().tween_callback(queue_free)
