extends Control

@export var musket: Musket
@export var lantern: Lantern
@export var barrel: Button
@export var ramrod: Button
@export var ball: ColorRect
@export var prompt: Label
@export var ramrod_travel: float = 150.0

var _ramrod_rest: Vector2


func _ready() -> void:
  _ramrod_rest = ramrod.position
  musket.equipped.connect(_update_visibility)
  musket.aiming_changed.connect(_update_visibility)
  lantern.carried_changed.connect(_update_visibility)
  musket.reload_changed.connect(_update_reload)
  _update_visibility()
  _update_reload()


func _update_visibility(_changed: bool = false) -> void:
  visible = musket.is_owned and not musket.is_aiming and not lantern.is_carried


func _update_reload() -> void:
  ramrod.position = _ramrod_rest + Vector2.DOWN * ramrod_travel * musket.ramrod_insertion
  barrel.disabled = musket.reload_state != Musket.ReloadState.EMPTY
  ball.visible = musket.reload_state == Musket.ReloadState.BALL_INSERTED
  match musket.reload_state:
    Musket.ReloadState.EMPTY:
      prompt.text = 'Click the barrel to insert a ball'
    Musket.ReloadState.BALL_INSERTED:
      prompt.text = 'Drag the ramrod down into the barrel'
    Musket.ReloadState.RAMMED:
      prompt.text = 'Pull the ramrod all the way back out'
    Musket.ReloadState.LOADED:
      prompt.text = 'Loaded! Hold RMB to aim, LMB to fire'
