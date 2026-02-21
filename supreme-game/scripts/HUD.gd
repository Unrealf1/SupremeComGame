extends CanvasLayer

@onready var hp_label: Label = $UI/VBox/HPLabel
@onready var distance_label: Label = $UI/VBox/DistanceLabel
@onready var player: Node = get_parent().get_node("Player")

func _process(_delta: float) -> void:
	if player == null:
		return
	hp_label.text = "HP: %d" % player.hp
	distance_label.text = "Distance: %d m" % int(player.metersFlown)
