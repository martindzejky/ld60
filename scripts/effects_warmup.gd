extends CanvasLayer

@export var musket: Musket


func _ready() -> void:
  await musket.warm_up_effects()
  if is_instance_valid(self):
    queue_free()
