extends Node

@export var scroll_speed := 6.0
@export var min_scroll_speed = 6.0
@export var max_scroll_speed := 12.0
@export var seconds_to_reach_max_speed := 600.0

var game_start_time_seconds : float
var global_meters_passed : float = 0.0


func start_game():
  game_start_time_seconds = Time.get_ticks_msec() / 1000.0
  global_meters_passed = 0.0


func update_global_state(delta : float):
  var currentTime := Time.get_ticks_msec() / 1000.0
  var time := currentTime - game_start_time_seconds
  var desiredSpeed = (max_scroll_speed - scroll_speed) * (time / seconds_to_reach_max_speed)
  scroll_speed = clamp(desiredSpeed, min_scroll_speed, max_scroll_speed)
  
  global_meters_passed += scroll_speed * delta
