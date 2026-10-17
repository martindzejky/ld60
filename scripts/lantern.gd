class_name Lantern
extends Node3D

@export var carrier: CharacterBody3D
@export var attachment_slot: Marker3D
@export var drop_slot: Marker3D
@export var carried_ui: Control
@export var light: OmniLight3D
@export var pickup_radius: float = 1.5
@export var max_energy: float = 100.0
@export var energy_drain: float = 5.0
@export var energy_per_press: float = 15.0
@export var min_radius: float = 0.7
@export var max_radius: float = 8.0
@export var min_brightness: float = 0.15
@export var max_brightness: float = 1.8

var energy: float = 0.0
var is_carried: bool = false
var _ground_parent: Node


func _ready() -> void:
  _ground_parent = get_parent()
  carried_ui.hide()
  energy = max_energy
  _update_light()


func _process(delta: float) -> void:
  energy = maxf(energy - energy_drain * delta, 0.0)
  _update_light()


func _update_light() -> void:
  var charge := energy / max_energy
  light.omni_range = lerpf(min_radius, max_radius, charge)
  light.light_energy = lerpf(min_brightness, max_brightness, charge)


func _unhandled_input(event: InputEvent) -> void:
  if is_carried and event.is_action_pressed('wind_lantern'):
    energy = minf(energy + energy_per_press, max_energy)
    _update_light()
    get_viewport().set_input_as_handled()
    return

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
