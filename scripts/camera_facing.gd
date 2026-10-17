class_name CameraFacing
extends Node3D


func _process(_delta: float) -> void:
  var camera := get_viewport().get_camera_3d()
  if camera:
    global_basis = camera.global_basis
