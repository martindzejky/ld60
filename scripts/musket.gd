class_name Musket
extends Node3D

signal equipped
signal aiming_changed(aiming: bool)
signal fired(hit: Dictionary)
signal reload_changed

enum ReloadState { EMPTY, BALL_INSERTED, RAMMED, LOADED }

@export var sprite: Sprite3D
@export var visuals: CameraFacing
@export var muzzle: Marker3D
@export var flash_scene: PackedScene
@export var smoke_scene: PackedScene
@export var shot_range: float = 30.0
@export var ray_height: float = 0.1

var is_owned: bool = false
var is_aiming: bool = false
var reload_state: ReloadState = ReloadState.EMPTY
var ramrod_insertion: float = 0.0


func insert_ball() -> void:
  if not is_owned or is_aiming or reload_state != ReloadState.EMPTY:
    return
  reload_state = ReloadState.BALL_INSERTED
  reload_changed.emit()


func move_ramrod(amount: float) -> void:
  if not is_owned or is_aiming or reload_state not in [ReloadState.BALL_INSERTED, ReloadState.RAMMED]:
    return
  ramrod_insertion = clampf(ramrod_insertion + amount, 0.0, 1.0)
  if ramrod_insertion == 1.0:
    reload_state = ReloadState.RAMMED
  elif ramrod_insertion == 0.0 and reload_state == ReloadState.RAMMED:
    reload_state = ReloadState.LOADED
  reload_changed.emit()


func equip() -> void:
  is_owned = true
  visuals.set_process(false)
  visuals.transform = Transform3D.IDENTITY
  sprite.rotation.z = 1.0
  equipped.emit()


func set_aiming(aiming: bool) -> void:
  if is_aiming == aiming:
    return
  is_aiming = aiming
  if not aiming:
    sprite.rotation.z = 1.0
  aiming_changed.emit(aiming)


func aim(direction: Vector2) -> void:
  var mirror := -1.0 if sprite.global_basis.determinant() < 0.0 else 1.0
  sprite.rotation.z = Vector2(direction.x * mirror, -direction.y).angle()


func fire(origin: Vector3, target: Vector3, excluded_body: RID) -> Dictionary:
  if not is_aiming or reload_state != ReloadState.LOADED:
    return {}
  var direction := Vector3(target.x - origin.x, 0.0, target.z - origin.z)
  if direction.is_zero_approx():
    return {}

  reload_state = ReloadState.EMPTY
  reload_changed.emit()

  var start := origin + Vector3.UP * ray_height
  var end := start + direction.normalized() * minf(direction.length(), shot_range)
  var query := PhysicsRayQueryParameters3D.create(start, end, 1, [excluded_body])
  var hit := get_world_3d().direct_space_state.intersect_ray(query)
  if not hit.is_empty():
    end = hit.position

  var flash := flash_scene.instantiate() as MuzzleFlash
  get_tree().current_scene.add_child(flash)
  flash.play(muzzle.global_position, end)
  var smoke := smoke_scene.instantiate() as CPUParticles3D
  smoke.top_level = true
  smoke.position = muzzle.global_position
  smoke.position.y = 0.0
  get_tree().current_scene.add_child(smoke)
  print('Musket fired: ', hit.get('collider', 'miss'))
  fired.emit(hit)
  return hit
