extends Node3D

@export var obstacle_scene: PackedScene
@export var spawn_interval := 5.0
@export var spawn_margin := 1.0

var screenHalfExtents : Vector2


func _ready() -> void:
  randomize()
  screenHalfExtents = ScreenBounds.get_half_extents(get_viewport())
  var timer := $Timer
  timer.wait_time = spawn_interval
  timer.timeout.connect(_spawn_obstacle)
  timer.start()


func _process(_delta: float) -> void:
  _update_screen_bounds()


func _update_screen_bounds() -> void:
  screenHalfExtents = ScreenBounds.get_half_extents(get_viewport())


func _spawn_obstacle() -> void:
  if obstacle_scene == null:
    return
  var obstacle := obstacle_scene.instantiate()
  var x := randf_range(0.0, screenHalfExtents.x)
  var y := -screenHalfExtents.y - spawn_margin
  if (randi() % 2 == 0):
    y *= -1.0
  obstacle.screen_half_height = screenHalfExtents.y
  add_child(obstacle)
  obstacle.global_position = Vector3(x, y, 0.0)
