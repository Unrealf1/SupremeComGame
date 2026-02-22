extends CanvasLayer

enum RunState {
  WAITING_TO_START,
  RUNNING,
  GAME_OVER
}

@onready var player: Node3D = get_parent().get_node("Player")
@onready var title_label: Label = $Overlay/Panel/VBox/Title
@onready var score_label: Label = $Overlay/Panel/VBox/Score
@onready var hint_label: Label = $Overlay/Panel/VBox/Hint

var state := RunState.WAITING_TO_START

func _ready() -> void:
  process_mode = Node.PROCESS_MODE_WHEN_PAUSED
  player.died.connect(_on_player_died)
  if GameState.auto_start_next_run:
    GameState.auto_start_next_run = false
    _start_run()
    return
  _show_start_overlay()
  get_tree().paused = true

func _unhandled_input(event: InputEvent) -> void:
  if not _is_confirm_input(event):
    return

  if state == RunState.WAITING_TO_START:
    _start_run()
  elif state == RunState.GAME_OVER:
    GameState.auto_start_next_run = true
    get_tree().paused = false
    get_tree().reload_current_scene()

func _start_run() -> void:
  state = RunState.RUNNING
  visible = false
  GameState.start_game()
  get_tree().paused = false

func _on_player_died(final_score: float) -> void:
  state = RunState.GAME_OVER
  visible = true
  title_label.text = "Run Over"
  score_label.text = "Score: %d m" % int(final_score)
  get_tree().paused = true

func _show_start_overlay() -> void:
  visible = true
  score_label.text = "Score: 0 m"

func _is_confirm_input(event: InputEvent) -> bool:
  if event is InputEventKey:
    return event.pressed and not event.echo and (event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER)
  return false
