extends CanvasLayer

## Nodo: CanvasLayer, Layer = 5 (igual que GameOverScreen; nunca se muestran
## al mismo tiempo, así que no importa que compartan layer)
## Hijos esperados: ColorRect "Dim", Label "VictoryLabel",
## Label "ScoreLabel", Label "TimeLabel", Button "RetryButton"

@onready var score_label: Label = $ScoreLabel
@onready var time_label: Label = $TimeLabel
@onready var retry_button: Button = $RetryButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	GameManager.victory_triggered.connect(_on_victory)
	retry_button.pressed.connect(_on_retry_pressed)

func _on_victory() -> void:
	score_label.text = "Puntos: %d" % GameManager.score
	time_label.text = "¡Derrotaste al jefe en %.1f segundos!" % GameManager.elapsed_time
	visible = true
	get_tree().paused = true

func _on_retry_pressed() -> void:
	get_tree().paused = false
	GameManager.reset()
	get_tree().reload_current_scene()
