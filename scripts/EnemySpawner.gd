extends Node2D

## Nodo: Node2D vacío, colócalo en cualquier parte de la escena Main.

@export var enemy_scene: PackedScene         # Enemy.tscn (insecto) — el básico
@export var spawn_radius: float = 500.0      # a qué distancia del jugador aparecen
@export var initial_interval: float = 1.5    # segundos entre spawns al inicio
@export var min_interval: float = 0.3        # el mínimo al que puede bajar
@export var difficulty_ramp: float = 0.02    # cuánto baja el intervalo en cada spawn
@export var boss_scene: PackedScene          # arrastra aquí Boss.tscn en el Inspector

@export_group("Variantes de enemigo")
@export var enemy_fast_scene: PackedScene       # EnemyFast.tscn (escorpión)
@export var enemy_fast_start_time: float = 60.0 # a partir de qué segundo puede aparecer
@export var enemy_fast_weight: float = 0.6      # qué tan seguido comparado al básico (peso 1.0)
@export var enemy_shooter_scene: PackedScene       # EnemyShooter.tscn
@export var enemy_shooter_start_time: float = 60.0
@export var enemy_shooter_weight: float = 0.3

var _interval: float
var _timer: float = 0.0

func _ready() -> void:
	_interval = initial_interval
	GameManager.boss_time_reached.connect(_spawn_boss)

func _process(delta: float) -> void:
	if GameManager.is_game_over or GameManager.boss_spawned:
		return
	_timer -= delta
	if _timer <= 0.0:
		_spawn_enemy()
		_interval = max(min_interval, _interval - difficulty_ramp)
		_timer = _interval

func _pick_enemy_scene() -> PackedScene:
	var t := GameManager.elapsed_time
	var pool: Array = [[enemy_scene, 1.0]]
	if enemy_fast_scene and t >= enemy_fast_start_time:
		pool.append([enemy_fast_scene, enemy_fast_weight])
	if enemy_shooter_scene and t >= enemy_shooter_start_time:
		pool.append([enemy_shooter_scene, enemy_shooter_weight])

	var total := 0.0
	for p in pool:
		total += p[1]
	var r := randf() * total
	var acc := 0.0
	for p in pool:
		acc += p[1]
		if r <= acc:
			return p[0]
	return enemy_scene

func _spawn_enemy() -> void:
	var scene := _pick_enemy_scene()
	if scene == null:
		return
	var player := get_tree().get_first_node_in_group("player")
	if player == null:
		return
	var angle := randf() * TAU
	var offset := Vector2(cos(angle), sin(angle)) * spawn_radius
	var enemy := scene.instantiate()
	get_tree().current_scene.add_child(enemy)
	enemy.global_position = player.global_position + offset

func _spawn_boss() -> void:
	if boss_scene == null:
		return
	var player := get_tree().get_first_node_in_group("player")
	if player == null:
		return
	var boss := boss_scene.instantiate()
	get_tree().current_scene.add_child(boss)
	boss.global_position = player.global_position + Vector2(0, -420)
