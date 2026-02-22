extends Node3D

@export var bullet_scene: PackedScene
@export var fire_interval := 1.0
@export var bullet_speed := 18.0
@export var bullet_damage := 5
@export var screen_half_extents := Vector2(16.0, 9.0)
@export var despawn_margin := 3.0
@export var muzzle_side_offset := 0.7
@export var muzzle_pair_separation := 0.4

@onready var timer: Timer = $FireTimer

func _ready() -> void:
  timer.wait_time = fire_interval
  timer.timeout.connect(_fire)
  timer.start()

func _process(delta: float) -> void:
  global_position.x -= GameState.scroll_speed * delta

  if global_position.x < -screen_half_extents.x - despawn_margin:
    queue_free()

func _fire() -> void:
  if bullet_scene == null:
    return

  var player := get_tree().current_scene.get_node_or_null("Player")
  if player == null:
    return

  var half_pair := muzzle_pair_separation * 0.5
  var heightOffset = 0.5
  _spawn_bullet_from_offset(Vector3(-muzzle_side_offset, -half_pair, heightOffset), player)
  _spawn_bullet_from_offset(Vector3(-muzzle_side_offset, half_pair, heightOffset), player)
  _spawn_bullet_from_offset(Vector3(muzzle_side_offset, -half_pair, heightOffset), player)
  _spawn_bullet_from_offset(Vector3(muzzle_side_offset, half_pair, heightOffset), player)

func _spawn_bullet_from_offset(local_offset: Vector3, player: Node3D) -> void:
  var bullet := bullet_scene.instantiate()
  get_tree().current_scene.add_child(bullet)
  bullet.global_basis = Basis.IDENTITY
  bullet.scale = Vector3.ONE

  var spawn_position := global_position + local_offset
  spawn_position.z = 0.0
  bullet.global_position = spawn_position

  var raw_dir: Vector3 = player.global_position - spawn_position
  raw_dir.z = 0.0
  var dirLen = raw_dir.length()
  if dirLen  <= 0.001:
    raw_dir = Vector3(0.0, 1.0, 0.0)
  else:
    var flightDuration = dirLen / bullet_speed
    var estimatedPos = player.global_position + Vector3(GameState.scroll_speed, 0.0, 0.0) * flightDuration
    raw_dir = estimatedPos - spawn_position

  bullet.direction = raw_dir.normalized()
  bullet.speed = bullet_speed
  bullet.damage = bullet_damage
  bullet.screen_half_extents = screen_half_extents
