extends Area3D

@export var speed := 10.0
@export var damage := 5
@export var direction := Vector3.ZERO
@export var screen_half_extents := Vector2(16.0, 9.0)
@export var despawn_margin := 3.0


func _ready() -> void:
  
  area_entered.connect(_on_area_entered)

func _process(delta: float) -> void:
  global_position += direction * speed * delta
  global_position.x -= GameState.scroll_speed * delta

  if (
    global_position.x < -screen_half_extents.x - despawn_margin
    or global_position.x > screen_half_extents.x + despawn_margin
    or global_position.y < -screen_half_extents.y - despawn_margin
    or global_position.y > screen_half_extents.y + despawn_margin
  ):
    queue_free()

func _on_area_entered(area: Area3D) -> void:
  var other_owner := area.get_parent()
  if other_owner and other_owner.has_method("apply_damage"):
    other_owner.apply_damage(damage)
    queue_free()
