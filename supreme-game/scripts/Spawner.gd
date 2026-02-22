extends Node3D

@export var obstacle_scene: PackedScene
@export var turret_scene: PackedScene
@export var spawn_interval := 2.5
@export var spawn_margin := 1.0
@export_range(0.0, 1.0) var turret_spawn_chance := 0.8

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

  var should_spawn_turret := turret_scene != null and randf() < turret_spawn_chance
  var spawned : Node3D
  if should_spawn_turret:
    spawned = turret_scene.instantiate()
  else:
    spawned = obstacle_scene.instantiate()
  add_child(spawned)
  
  if should_spawn_turret:
    spawned.global_position = Vector3(screenHalfExtents.x, -screenHalfExtents.y - spawn_margin, 0.0)
    spawned.screen_half_extents = screenHalfExtents
  else:
    # spawning moving obstacle
    var x := randf_range(0, screenHalfExtents.x)
    var y := -screenHalfExtents.y - spawn_margin
    if randi() % 2 == 0:
      y *= -1.0
    spawned.direction = Vector3(0.0, -sign(y), 0.0)
    spawned.global_position = Vector3(x, y, 0.0)
    spawned.screen_half_height = screenHalfExtents.y
