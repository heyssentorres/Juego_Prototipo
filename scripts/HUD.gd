extends CanvasLayer

## Nodo: CanvasLayer
## Hijos esperados: Label "ScoreLabel", Label "TimeLabel", Label "HealthLabel",
## ProgressBar "XPBar", ProgressBar "BossHealthBar"

@onready var score_label: Label = $ScoreLabel
@onready var time_label: Label = $TimeLabel
@onready var health_label: Label = $HealthLabel
@onready var xp_bar: ProgressBar = $XPBar
@onready var boss_bar: ProgressBar = $BossHealthBar

var _player: Node

func _ready() -> void:
	_player = get_tree().get_first_node_in_group("player")
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.game_over_triggered.connect(_on_game_over)
	GameManager.xp_changed.connect(_on_xp_changed)
	_on_xp_changed(GameManager.xp, GameManager.xp_to_next)
	boss_bar.visible = false

func _process(_delta: float) -> void:
	time_label.text = "Tiempo: %.1f" % GameManager.elapsed_time
	if not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player")
	if is_instance_valid(_player):
		health_label.text = "Vida: %d" % int(_player.health)

	var boss := get_tree().get_first_node_in_group("boss")
	if is_instance_valid(boss):
		boss_bar.visible = true
		boss_bar.max_value = boss.max_health
		boss_bar.value = boss.health
	else:
		boss_bar.visible = false

func _on_score_changed(new_score: int) -> void:
	score_label.text = "Puntos: %d" % new_score

func _on_xp_changed(current: int, needed: int) -> void:
	xp_bar.max_value = needed
	xp_bar.value = current

func _on_game_over() -> void:
	time_label.text += "  —  GAME OVER"
