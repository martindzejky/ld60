extends CharacterBody3D

@export var speed: float = 4.0
@export var dash_speed: float = 14.0
@export var dash_duration: float = 0.18
@export var dash_recovery: float = 0.5
@export var dash_cooldown: float = 4.0

var _last_direction: Vector2 = Vector2.DOWN
var _dash_direction: Vector2 = Vector2.DOWN
var _dash_timer: Timer = Timer.new()
var _recovery_timer: Timer = Timer.new()
var _cooldown_timer: Timer = Timer.new()


func _ready() -> void:
  _dash_timer.wait_time = dash_duration
  _recovery_timer.wait_time = dash_recovery
  _cooldown_timer.wait_time = dash_cooldown
  _dash_timer.timeout.connect(_on_dash_timer_timeout)
  var timers: Array[Timer] = [_dash_timer, _recovery_timer, _cooldown_timer]
  for timer: Timer in timers:
    timer.one_shot = true
    timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
    add_child(timer)


func _unhandled_input(event: InputEvent) -> void:
  if not event.is_action_pressed('dash') or event.is_echo():
    return
  if not _cooldown_timer.is_stopped() or not _dash_timer.is_stopped() or not _recovery_timer.is_stopped():
    return

  var direction := Input.get_vector('move_left', 'move_right', 'move_up', 'move_down')
  _dash_direction = _last_direction if direction.is_zero_approx() else direction.normalized()
  _dash_timer.start()
  _cooldown_timer.start()
  get_viewport().set_input_as_handled()


func _physics_process(_delta: float) -> void:
  var direction := Input.get_vector('move_left', 'move_right', 'move_up', 'move_down')
  if not direction.is_zero_approx():
    _last_direction = direction.normalized()

  if not _dash_timer.is_stopped():
    velocity = Vector3(_dash_direction.x, 0.0, _dash_direction.y) * dash_speed
  elif not _recovery_timer.is_stopped():
    velocity = Vector3.ZERO
  else:
    velocity = Vector3(direction.x, 0.0, direction.y) * speed

  move_and_slide()


func _on_dash_timer_timeout() -> void:
  _recovery_timer.start()
