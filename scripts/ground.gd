extends CSGPolygon3D


func _ready() -> void:
  var boundary := StaticBody3D.new()
  boundary.name = 'boundary'
  boundary.collision_layer = 4
  boundary.collision_mask = 0
  add_child(boundary)

  for index: int in range(polygon.size()):
    var start := polygon[index]
    var end := polygon[(index + 1) % polygon.size()]
    var edge := end - start
    if edge.is_zero_approx():
      continue
    var midpoint := (start + end) * 0.5
    var shape := BoxShape3D.new()
    # local XY is the floor; local Z points up after the ground's rotation
    shape.size = Vector3(edge.length() + 0.1, 0.1, 4.0)
    var collider := CollisionShape3D.new()
    collider.shape = shape
    collider.position = Vector3(midpoint.x, midpoint.y, 2.0)
    collider.rotation.z = edge.angle()
    boundary.add_child(collider)
