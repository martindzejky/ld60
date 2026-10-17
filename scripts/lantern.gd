class_name Lantern
extends Node3D

signal carried_changed(carried: bool)

@export var light: OmniLight3D
@export var visuals: CameraFacing
@export var max_energy: float = 100.0
@export var energy_drain: float = 5.0
@export var energy_per_press: float = 15.0
@export var min_radius: float = 0.7
@export var max_radius: float = 8.0
@export var min_brightness: float = 0.15
@export var max_brightness: float = 1.8

var energy: float = 0.0
var is_carried: bool = false


func _ready() -> void:
  energy = max_energy
  _update_light()


func _process(delta: float) -> void:
  energy = maxf(energy - energy_drain * delta, 0.0)
  _update_light()


func _update_light() -> void:
  var charge := energy / max_energy
  light.omni_range = lerpf(min_radius, max_radius, charge)
  light.light_energy = lerpf(min_brightness, max_brightness, charge)


func set_carried(carried: bool) -> void:
  is_carried = carried
  visuals.set_process(not carried)
  if carried:
    visuals.transform = Transform3D.IDENTITY
  carried_changed.emit(carried)


func charge() -> void:
  energy = minf(energy + energy_per_press, max_energy)
  _update_light()
