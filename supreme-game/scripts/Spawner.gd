extends Node3D

@export var obstacle_scene: PackedScene
@export var obstacle_scene2: PackedScene
@export var obstacle_scene3: PackedScene
@export var bonus_scene: PackedScene
@export var turret_scene: PackedScene
@export var aeon_turret_scene: PackedScene
@export var spawn_interval_seconds := Vector2(1.0, 3.0)
var small_interval_seconds = 0.8
var small_interval_chance = 0.0
@export var spawn_margin := 1.0
@export_range(0.0, 1.0) var turret_spawn_chance := 0.9

var screenHalfExtents : Vector2
var nextSpawnAtMsec : float

var aeon_spawn_chance = 0.3


func _ready() -> void:
  randomize()
  screenHalfExtents = ScreenBounds.get_half_extents(get_viewport())
  nextSpawnAtMsec = Time.get_ticks_msec() + spawn_interval_seconds.y * 1000.0


func _process(_delta: float) -> void:
  _update_screen_bounds()
  var curTime = Time.get_ticks_msec()
  if nextSpawnAtMsec <= curTime:
    _spawn_obstacle()
    if randf() < small_interval_chance:
      nextSpawnAtMsec = curTime + small_interval_chance * 1000.0
    else:
      nextSpawnAtMsec = curTime + randf_range(spawn_interval_seconds.x, spawn_interval_seconds.y) * 1000.0


func _update_screen_bounds() -> void:
  screenHalfExtents = ScreenBounds.get_half_extents(get_viewport())


func _spawn_obstacle() -> void:
  if obstacle_scene == null:
    return

  var spawned : Node3D
  if randf() < aeon_spawn_chance:
    spawned = aeon_turret_scene.instantiate()
  else:
    spawned = turret_scene.instantiate()
  add_child(spawned)
  spawned.global_position = Vector3(screenHalfExtents.x + spawn_margin, -screenHalfExtents.y + spawn_margin, 0.0)
  spawned.screen_half_extents = screenHalfExtents
  var additional = randf()
  if additional < 0.25:
    # spawning moving obstacle
    var obstacle = null
    if randf() < 0.5:
      obstacle = obstacle_scene2.instantiate()
    else:
      obstacle = obstacle_scene3.instantiate()
    add_child(obstacle)
    var x := randf_range(0, screenHalfExtents.x)
    var y := -screenHalfExtents.y - spawn_margin
    if randi() % 2 == 0:
      y *= -1.0
    obstacle.direction = Vector3(0.0, -sign(y), 0.0)
    obstacle.global_position = Vector3(x, y, 0.0)
    obstacle.screen_half_height = screenHalfExtents.y
  elif additional < 0.5:
    var bonus = bonus_scene.instantiate()
    add_child(bonus)
    var x := randf_range(0, screenHalfExtents.x)
    var y := -screenHalfExtents.y - spawn_margin
    if randi() % 2 == 0:
      y *= -1.0
    bonus.direction = Vector3(0.0, -sign(y), 0.0)
    bonus.global_position = Vector3(x, y, 0.0)
    bonus.screen_half_height = screenHalfExtents.y
