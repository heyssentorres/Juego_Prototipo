extends CanvasLayer

## Nodo: CanvasLayer, Layer = 5 (para quedar por encima del HUD)
## Hijos esperados: ColorRect "Dim", TextureRect "GameOverImage",
## Label "ScoreLabel", Label "TimeLabel", Button "RetryButton"

@onready var score_label: Label = $ScoreLabel
@onready var time_label: Label = $TimeLabel
@onready var retry_button: Button = $RetryButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS  # sigue activo aunque el juego esté en pausa
	visible = false
	GameManager.game_over_triggered.connect(_on_game_over)
	retry_button.pressed.connect(_on_retry_pressed)

func _on_game_over() -> void:
	score_label.text = "Puntos: %d" % GameManager.score
	time_label.text = "Sobreviviste %.1f segundos" % GameManager.elapsed_time
	visible = true
	get_tree().paused = true

func _on_retry_pressed() -> void:
	get_tree().paused = false
	GameManager.reset()
	get_tree().reload_current_scene()
