extends Node3D

@export var carrier: CharacterBody3D
@export var attachment_slot: Marker3D
@export var drop_slot: Marker3D
@export var carried_ui: Control
@export var pickup_radius: float = 1.5

var is_carried: bool = false
var _ground_parent: Node


func _ready() -> void:
  _ground_parent = get_parent()
  carried_ui.hide()


func _unhandled_input(event: InputEvent) -> void:
  if not event.is_action_pressed('interact') or event.is_echo():
    return

  if is_carried:
    reparent(_ground_parent)
    global_position = drop_slot.global_position
    is_carried = false
    carried_ui.hide()
  elif global_position.distance_squared_to(carrier.global_position) <= pickup_radius * pickup_radius:
    reparent(attachment_slot, false)
    position = Vector3.ZERO
    is_carried = true
    carried_ui.show()
  else:
    return

  get_viewport().set_input_as_handled()
