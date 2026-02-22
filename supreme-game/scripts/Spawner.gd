extends Node3D

@export var obstacle_scene: PackedScene
@export var turret_scene: PackedScene
@export var spawn_interval_seconds := Vector2(2.0, 3.0)
@export var spawn_margin := 1.0
@export_range(0.0, 1.0) var turret_spawn_chance := 0.8

var screenHalfExtents : Vector2
var nextSpawnAtMsec : float


func _ready() -> void:
  randomize()
  screenHalfExtents = ScreenBounds.get_half_extents(get_viewport())
  nextSpawnAtMsec = Time.get_ticks_msec() + spawn_interval_seconds.y * 1000.0


func _process(_delta: float) -> void:
  _update_screen_bounds()
  var curTime = Time.get_ticks_msec()
  if nextSpawnAtMsec <= curTime:
    _spawn_obstacle()
    nextSpawnAtMsec = curTime + randf_range(spawn_interval_seconds.x, spawn_interval_seconds.y) * 1000.0


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
    spawned.global_position = Vector3(screenHalfExtents.x + spawn_margin, -screenHalfExtents.y + spawn_margin, 0.0)
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
