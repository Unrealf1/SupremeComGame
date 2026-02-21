extends Area3D

@export var speed := 6.0
@export var damage := 10
@export var screen_half_height := 10.0
@export var despawn_margin := 2.0

var direction = Vector3(0.0, 1.0, 0.0)

func _ready() -> void:
  area_entered.connect(_on_area_entered)

func _process(delta: float) -> void:
  global_position += direction * speed * delta
  global_position.x -= GameState.scroll_speed * delta
  if global_position.y > screen_half_height + despawn_margin:
    queue_free()


func _on_area_entered(area: Area3D) -> void:
  var otherOwner := area.get_parent()
  if otherOwner and otherOwner.has_method("apply_damage"):
    otherOwner.apply_damage(damage)
  queue_free()
