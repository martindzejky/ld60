class_name Musket
extends Node3D

signal equipped
signal aiming_changed(aiming: bool)

@export var sprite: Sprite3D
@export var visuals: CameraFacing

var is_owned: bool = false
var is_aiming: bool = false


func equip() -> void:
  is_owned = true
  visuals.set_process(false)
  visuals.transform = Transform3D.IDENTITY
  sprite.rotation.z = 1.0
  equipped.emit()


func set_aiming(aiming: bool) -> void:
  if is_aiming == aiming:
    return
  is_aiming = aiming
  if not aiming:
    sprite.rotation.z = 1.0
  aiming_changed.emit(aiming)


func aim(direction: Vector2) -> void:
  var mirror := -1.0 if sprite.global_basis.determinant() < 0.0 else 1.0
  sprite.rotation.z = Vector2(direction.x * mirror, -direction.y).angle()


func fire() -> void:
  if is_aiming:
    print('Musket fired')
