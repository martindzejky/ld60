class_name Player
extends CharacterBody3D

@export var flip: Node3D
@export var musket: Musket
@export var lantern: Lantern
@export var lantern_slot: Marker3D
@export var drop_slot: Marker3D
@export var musket_back_slot: Marker3D
@export var musket_aim_slot: Marker3D
@export var pickup_radius: float = 1.5
@export var speed: float = 4.0
@export var dash_speed: float = 14.0
@export var dash_duration: float = 0.18
@export var dash_recovery: float = 0.5
@export var dash_cooldown: float = 4.0
@export var ramrod_drag_distance: float = 150.0

var _last_direction: Vector2 = Vector2.DOWN
var _dash_direction: Vector2 = Vector2.DOWN
var _dash_timer: Timer = Timer.new()
var _recovery_timer: Timer = Timer.new()
var _cooldown_timer: Timer = Timer.new()
var _item_parent: Node
var _shot_requested: bool = false
var _dragging_ramrod: bool = false


func _ready() -> void:
  _item_parent = lantern.get_parent()
  _dash_timer.wait_time = dash_duration
  _recovery_timer.wait_time = dash_recovery
  _cooldown_timer.wait_time = dash_cooldown
  _dash_timer.timeout.connect(_on_dash_timer_timeout)
  var timers: Array[Timer] = [_dash_timer, _recovery_timer, _cooldown_timer]
  for timer: Timer in timers:
    timer.one_shot = true
    timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
    add_child(timer)


func _process(_delta: float) -> void:
  var facing := velocity.x
  if _aiming_requested():
    var camera := get_viewport().get_camera_3d()
    facing = get_viewport().get_mouse_position().x - camera.unproject_position(global_position).x
  if not is_zero_approx(facing):
    flip.scale.x = -1.0 if facing < 0.0 else 1.0
  _update_equipment()


func _input(event: InputEvent) -> void:
  if not _dragging_ramrod:
    return
  if event is InputEventMouseMotion:
    musket.move_ramrod(event.relative.y / ramrod_drag_distance)
    get_viewport().set_input_as_handled()
  elif event.is_action_released('fire_musket'):
    _dragging_ramrod = false


func _unhandled_input(event: InputEvent) -> void:
  if event.is_echo():
    return

  if event.is_action_pressed('interact'):
    _interact()
  elif event.is_action_pressed('ignite_musket'):
    if (
      not lantern.is_carried and _within_reach(lantern)
      and lantern.energy >= lantern.max_energy * 0.3
    ):
      musket.ignite()
  elif event.is_action_pressed('fire_musket'):
    _shot_requested = _aiming_requested()
  elif event.is_action_pressed('dash'):
    _dash()
  else:
    return
  get_viewport().set_input_as_handled()


func _on_lantern_pressed() -> void:
  if lantern.is_carried:
    lantern.charge()


func _on_barrel_pressed() -> void:
  if not lantern.is_carried:
    musket.insert_ball()


func _on_ramrod_gui_input(event: InputEvent) -> void:
  if event.is_action_pressed('fire_musket') and not lantern.is_carried:
    _dragging_ramrod = musket.reload_state in [Musket.ReloadState.BALL_INSERTED, Musket.ReloadState.RAMMED]


func _dash() -> void:
  if (
    not _cooldown_timer.is_stopped() or not _dash_timer.is_stopped()
    or not _recovery_timer.is_stopped()
  ):
    return

  var direction := Input.get_vector('move_left', 'move_right', 'move_up', 'move_down')
  _dash_direction = _last_direction if direction.is_zero_approx() else direction.normalized()
  _dash_timer.start()
  _cooldown_timer.start()


func _interact() -> void:
  _dragging_ramrod = false
  if not musket.is_owned and _within_reach(musket):
    _attach(musket, musket_back_slot)
    musket.equip()
  elif lantern.is_carried:
    lantern.reparent(_item_parent)
    lantern.global_transform = Transform3D(Basis.IDENTITY, drop_slot.global_position)
    lantern.set_carried(false)
  elif _within_reach(lantern):
    _attach(lantern, lantern_slot)
    lantern.set_carried(true)
  _update_equipment()


func _within_reach(item: Node3D) -> bool:
  return global_position.distance_squared_to(item.global_position) <= pickup_radius * pickup_radius


func _attach(item: Node3D, slot: Marker3D) -> void:
  item.reparent(slot, false)
  item.transform = Transform3D.IDENTITY


func _update_equipment() -> void:
  var aiming := _aiming_requested()
  musket.set_aiming(aiming)
  if not musket.is_owned:
    return
  var slot := musket_aim_slot if aiming else musket_back_slot
  if musket.get_parent() != slot:
    _attach(musket, slot)
  if aiming:
    var camera := get_viewport().get_camera_3d()
    var origin := camera.unproject_position(musket.global_position)
    musket.aim(get_viewport().get_mouse_position() - origin)


func _aiming_requested() -> bool:
  return (
    musket.is_owned and not lantern.is_carried and not _dragging_ramrod
    and Input.is_action_pressed('aim_musket')
  )


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
  if _shot_requested:
    _shot_requested = false
    _update_equipment()
    if musket.is_aiming:
      var camera := get_viewport().get_camera_3d()
      var mouse := get_viewport().get_mouse_position()
      var target: Variant = Plane(Vector3.UP).intersects_ray(
        camera.project_ray_origin(mouse), camera.project_ray_normal(mouse)
      )
      if target != null:
        musket.fire(global_position, target, get_rid())


func _on_dash_timer_timeout() -> void:
  _recovery_timer.start()
