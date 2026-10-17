class_name Musket
extends Node3D

@export var carrier: Player
@export var lantern: Lantern
@export var back_slot: Marker3D
@export var aim_slot: Marker3D
@export var sprite: Sprite3D
@export var visuals: CameraFacing
@export var pickup_radius: float = 1.5

var is_owned: bool = false
var is_aiming: bool:
  get:
    return _can_aim()


func _process(_delta: float) -> void:
  if not is_owned:
    return

  var slot := aim_slot if is_aiming else back_slot
  if get_parent() != slot:
    reparent(slot, false)
    transform = Transform3D.IDENTITY

  if is_aiming:
    var camera := get_viewport().get_camera_3d()
    var origin := camera.unproject_position(global_position)
    var direction := get_viewport().get_mouse_position() - origin
    var mirror := -1.0 if sprite.global_basis.determinant() < 0.0 else 1.0
    sprite.rotation.z = Vector2(direction.x * mirror, -direction.y).angle()
  else:
    sprite.rotation.z = 1.0


func _can_aim() -> bool:
  return is_owned and not lantern.is_carried and Input.is_action_pressed('aim_musket')


func _unhandled_input(event: InputEvent) -> void:
  if event.is_echo():
    return

  if not is_owned and event.is_action_pressed('interact'):
    if global_position.distance_squared_to(carrier.global_position) > pickup_radius * pickup_radius:
      return
    is_owned = true
    reparent(back_slot, false)
    transform = Transform3D.IDENTITY
    visuals.set_process(false)
    visuals.transform = Transform3D.IDENTITY
    get_viewport().set_input_as_handled()
  elif event.is_action_pressed('fire_musket') and _can_aim():
    print('Musket fired')
    get_viewport().set_input_as_handled()
