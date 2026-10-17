class_name Enemy
extends Area3D

@export var target: Player
@export var head: Sprite3D
@export var speed: float = 0.8
@export var bite_range: float = 1.15
@export var windup_duration: float = 1.0
@export var mouth_open_height: float = 0.45

var _closed_head_y: float
var _biting: bool = false
var _bite_tween: Tween


func _ready() -> void:
  _closed_head_y = head.position.y


func _physics_process(delta: float) -> void:
  if target.is_dead or _biting:
    return
  if _within_bite_range():
    _start_bite()
  else:
    global_position = global_position.move_toward(target.global_position, speed * delta)


func take_shot() -> void:
  set_physics_process(false)
  if _bite_tween and _bite_tween.is_valid():
    _bite_tween.kill()
  collision_layer = 0
  hide()
  queue_free()


func _within_bite_range() -> bool:
  return global_position.distance_squared_to(target.global_position) <= bite_range * bite_range


func _start_bite() -> void:
  _biting = true
  if _bite_tween and _bite_tween.is_valid():
    _bite_tween.kill()
  _bite_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
  _bite_tween.tween_property(head, 'position:y', _closed_head_y + mouth_open_height, windup_duration)
  _bite_tween.tween_callback(_bite)


func _bite() -> void:
  head.position.y = _closed_head_y
  if not target.is_dead and _within_bite_range():
    target.take_bite()
  _biting = false
