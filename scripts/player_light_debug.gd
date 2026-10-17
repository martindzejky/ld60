extends Label

@export var player: Player


func _ready() -> void:
  player.light_changed.connect(_on_light_changed)
  _on_light_changed(player.is_lit)


func _on_light_changed(lit: bool) -> void:
  text = 'Player: IN LIGHT' if lit else 'Player: IN DARKNESS'
