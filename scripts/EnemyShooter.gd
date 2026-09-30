extends Area2D

## Nodo: Area2D (grupo "enemies")
## Hijos esperados: CollisionShape2D, Sprite2D (visual: enemy_shooter.png)
## A diferencia de Enemy.gd, este NO persigue hasta pegarse: se acerca solo
## hasta "stop_distance" y desde ahí dispara proyectiles al jugador.

@export var speed: float = 70.0
@export var max_health: float = 45.0
@export var contact_damage: float = 8.0
@export var contact_cooldown: float = 0.6
@export var score_value: int = 20
@export var xp_value: int = 8
@export var xp_orb_scene: PackedScene        # arrastra aquí XPOrb.tscn
@export var facing_offset_degrees: float = 0.0

@export_group("Disparo a distancia")
@export var stop_distance: float = 260.0     # se detiene a esta distancia del jugador
@export var fire_rate: float = 1.8           # segundos entre disparos
@export var projectile_scene: PackedScene    # arrastra aquí EnemyBullet.tscn
@export var projectile_speed: float = 260.0
@export var projectile_damage: float = 8.0

var health: float
var _player: Node2D
var _hit_timer: float = 0.0
var _fire_timer: float = 0.0
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	health = max_health
	add_to_group("enemies")
	_player = get_tree().get_first_node_in_group("player")
	area_entered.connect(_on_area_entered)

func _process(delta: float) -> void:
	if is_instance_valid(_player):
		var to_player := _player.global_position - global_position
		var dist := to_player.length()
		var dir := to_player.normalized()
		rotation = dir.angle() + deg_to_rad(facing_offset_degrees)
		if dist > stop_distance:
			position += dir * speed * delta

		_fire_timer -= delta
		if _fire_timer <= 0.0:
			_fire_at_player(dir)
			_fire_timer = fire_rate

	_hit_timer -= delta

func _fire_at_player(direction: Vector2) -> void:
	if projectile_scene == null:
		return
	var proj := projectile_scene.instantiate()
	proj.direction = direction
	proj.speed = projectile_speed
	proj.damage = projectile_damage
	proj.global_position = global_position
	get_tree().current_scene.call_deferred("add_child", proj)

func take_damage(amount: float) -> void:
	_flash_hit()
	health -= amount
	if health <= 0.0:
		GameManager.add_score(score_value)
		GameManager.notify_enemy_killed(max_health)
		_drop_xp_orb()
		queue_free()

func _flash_hit() -> void:
	if sprite == null:
		return
	sprite.modulate = Color(1.0, 0.3, 0.3)
	var tween := create_tween()
	tween.tween_property(sprite, "modulate", Color(1.0, 1.0, 1.0), 0.15)

func _drop_xp_orb() -> void:
	if xp_orb_scene == null:
		return
	var orb := xp_orb_scene.instantiate()
	orb.xp_value = xp_value
	orb.global_position = global_position
	get_tree().current_scene.call_deferred("add_child", orb)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player") and _hit_timer <= 0.0:
		if area.has_method("take_damage"):
			area.take_damage(contact_damage)
		_hit_timer = contact_cooldown
