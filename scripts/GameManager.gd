extends Node

## Este script va como AUTOLOAD (singleton), no se pega a ningún nodo de escena.
## Project Settings > Autoload > agrega este archivo con el nombre "GameManager".
## Así cualquier script puede llamar GameManager.algo() sin buscarlo en el árbol.

signal score_changed(new_score: int)
signal xp_changed(current: int, needed: int)
signal level_up_triggered
signal game_over_triggered
signal boss_time_reached
signal victory_triggered

var score: int = 0
var elapsed_time: float = 0.0
var is_game_over: bool = false

var xp: int = 0
var level: int = 1
var xp_to_next: int = 5

var boss_trigger_time: float = 300   # 5 minutos
var boss_spawned: bool = false

func _process(delta: float) -> void:
	if not is_game_over:
		elapsed_time += delta
		if not boss_spawned and elapsed_time >= boss_trigger_time:
			boss_spawned = true
			boss_time_reached.emit()

func add_score(amount: int) -> void:
	score += amount
	score_changed.emit(score)

func add_xp(amount: int) -> void:
	if is_game_over:
		return
	xp += amount
	xp_changed.emit(xp, xp_to_next)
	if xp >= xp_to_next:
		xp -= xp_to_next
		level += 1
		xp_to_next = int(xp_to_next * 1.35) + 2
		level_up_triggered.emit()
		xp_changed.emit(xp, xp_to_next)

func notify_enemy_killed(enemy_max_health: float) -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player and player.has_method("apply_lifesteal"):
		player.apply_lifesteal(enemy_max_health)

func game_over() -> void:
	if is_game_over:
		return
	is_game_over = true
	game_over_triggered.emit()

func victory() -> void:
	if is_game_over:
		return
	is_game_over = true
	victory_triggered.emit()

func reset() -> void:
	score = 0
	elapsed_time = 0.0
	is_game_over = false
	xp = 0
	level = 1
	xp_to_next = 5
	boss_spawned = false
