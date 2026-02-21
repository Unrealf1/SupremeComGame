extends Node3D

@export var speed := 12.0
@export var MAX_HP := 50

var hp := MAX_HP
var screenHalfExtents : Vector2
var metersFlown : float = 0.0


func _ready() -> void:
  screenHalfExtents = ScreenBounds.get_half_extents(get_viewport())
  GameState.start_game()


func _process(delta: float) -> void:
  GameState.update_global_state(delta)
  screenHalfExtents = ScreenBounds.get_half_extents(get_viewport())
  var input_vec := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
  global_position += Vector3(input_vec.x, -input_vec.y, 0.0) * speed * delta

  global_position.x = clamp(global_position.x, -screenHalfExtents.x, screenHalfExtents.x)
  global_position.y = clamp(global_position.y, -screenHalfExtents.y, screenHalfExtents.y)
  global_position.z = 0.0
  metersFlown = GameState.global_meters_passed + (global_position.x - -screenHalfExtents.x)
  print("Meters flown: ", metersFlown)
  print("Global Meters flown: ", GameState.global_meters_passed)
  print("Local Meters flown: ", metersFlown - GameState.global_meters_passed)
  print("Scroll speed: ", GameState.scroll_speed)


func apply_damage(amount: int) -> void:
  hp = max(hp - amount, 0)
  print("[Apply Damage] Hp left: ", hp, " damage: ", amount)
  if hp <= 0:
    get_tree().reload_current_scene()
