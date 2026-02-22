extends Area3D

@export var bullet_scene: PackedScene
@export var fire_interval := 3.0
@export var initial_fire_interval := 1.5
@export var bullet_speed := 8.0
@export var bullet_damage := 15
@export var collision_damage := 10
@export var screen_half_extents := Vector2(16.0, 9.0)
@export var despawn_margin := 3.0
@export var muzzle_offset := Vector3(0.0, 0.5, 0.0)
@export var bullet_scale_multiplier := 3.0

@onready var timer: Timer = $FireTimer

func _ready() -> void:
  area_entered.connect(_on_area_entered)
  timer.wait_time = initial_fire_interval
  timer.timeout.connect(_fire)
  timer.start()

func _process(delta: float) -> void:
  global_position.x -= GameState.scroll_speed * delta

  if global_position.x < -screen_half_extents.x - despawn_margin:
    queue_free()

func _fire() -> void:
  timer.wait_time = fire_interval
  if bullet_scene == null:
    return

  var bullet := bullet_scene.instantiate()
  get_tree().current_scene.add_child(bullet)
  bullet.global_basis = Basis.IDENTITY
  bullet.scale = Vector3.ONE * bullet_scale_multiplier

  var spawn_position := global_position + muzzle_offset
  spawn_position.z = 0.0
  bullet.global_position = spawn_position
  bullet.direction = Vector3(0.0, 1.0, 0.0)
  bullet.speed = bullet_speed
  bullet.damage = bullet_damage
  bullet.screen_half_extents = screen_half_extents

func _on_area_entered(area: Area3D) -> void:
  var other_owner := area.get_parent()
  if other_owner and other_owner.has_method("apply_damage"):
    other_owner.apply_damage(collision_damage)
    queue_free()
