extends HBoxContainer

@export var lantern: Lantern


func _ready() -> void:
  lantern.carried_changed.connect(_on_carried_changed)
  _on_carried_changed(lantern.is_carried)


func _on_carried_changed(carried: bool) -> void:
  visible = carried
