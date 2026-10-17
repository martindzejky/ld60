extends Button

@export var lantern: Lantern
@export var lever: Control


func _ready() -> void:
  lantern.carried_changed.connect(_on_carried_changed)
  lantern.lever_changed.connect(_on_lever_changed)
  _on_carried_changed(lantern.is_carried)
  _on_lever_changed(lantern.lever_openness)


func _on_carried_changed(carried: bool) -> void:
  visible = carried


func _on_lever_changed(openness: float) -> void:
  lever.rotation = lerpf(0.0, deg_to_rad(-55.0), openness)
