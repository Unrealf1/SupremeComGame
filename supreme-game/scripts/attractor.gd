extends Area3D


var player: Node3D
var attraction_speed = 5.0


func _ready() -> void:
  player = null
  area_entered.connect(_on_area_entered)
  area_exited.connect(_on_area_exit)


func _process(delta : float) -> void:
  if player == null:
    return
    
  var dirToAttractor = global_position - player.global_position
  player.global_position += dirToAttractor.normalized() * attraction_speed * delta


func _on_area_entered(area: Area3D) -> void:
  var other_owner := area.get_parent()
  if other_owner and other_owner.has_method("is_player"):
    player = other_owner
    
func _on_area_exit(area: Area3D):
  var other_owner := area.get_parent()
  if other_owner == player:
    player = null
