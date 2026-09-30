extends Area2D

## Nodo: Area2D (grupo "player")
## Hijos esperados: CollisionShape2D, Sprite2D, Camera2D

@export var speed: float = 220.0
@export var max_health: float = 100.0
@export var attack_range: float = 260.0
@export var fire_rate: float = 0.4          # segundos entre disparos
@export var bullet_scene: PackedScene        # arrastra aquí Bullet.tscn en el Inspector

@onready var sprite: Sprite2D = $Sprite2D

var health: float
var _fire_timer: float = 0.0

# Mejoras acumulables (las modifica LevelUpScreen al elegir una carta)
var projectile_count: int = 1
var damage_multiplier: float = 1.0
var shield_charges: int = 0
var magnet_radius: float = 0.0
var pierce_count: int = 0
var lifesteal_percent: float = 0.0

var _base_bullet_damage: float = 10.0   # debe coincidir con Bullet.gd > damage
var _spread_degrees: float = 18.0        # separación entre balas cuando hay varias

## Pool de mejoras. LevelUpScreen.gd elige 3 al azar de esta lista cada vez
## que subes de nivel. "id" es lo que se le pasa a apply_upgrade().
const UPGRADE_POOL: Array = [
	{"id": "fire_rate", "label": "Cadencia de disparo +"},
	{"id": "damage", "label": "Daño +25%"},
	{"id": "projectile", "label": "Proyectil extra"},
	{"id": "shield", "label": "Escudo (+1 carga)"},
	{"id": "max_health", "label": "Vida máxima +20"},
	{"id": "magnet", "label": "Imán de XP +"},
	{"id": "piercing", "label": "Balas perforantes +1"},
	{"id": "lifesteal", "label": "Vampiro: robar vida al matar"},
]

func _ready() -> void:
	health = max_health
	add_to_group("player")

func _process(delta: float) -> void:
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	position += input_dir * speed * delta
	if input_dir != Vector2.ZERO and sprite:
		sprite.rotation = input_dir.angle()  # sin input, se queda mirando hacia donde iba

	_fire_timer -= delta
	if _fire_timer <= 0.0:
		_try_fire()
		_fire_timer = fire_rate

func _try_fire() -> void:
	var target := _find_nearest_enemy()
	if target == null or bullet_scene == null:
		return
	var base_dir := (target.global_position - global_position).normalized()
	var spread_rad := deg_to_rad(_spread_degrees)
	for i in range(projectile_count):
		var offset := (i - (projectile_count - 1) / 2.0) * spread_rad
		var bullet := bullet_scene.instantiate()
		bullet.direction = base_dir.rotated(offset)
		bullet.damage = _base_bullet_damage * damage_multiplier
		bullet.pierce = pierce_count
		bullet.global_position = global_position
		get_tree().current_scene.add_child(bullet)

func _find_nearest_enemy() -> Node2D:
	var enemies := get_tree().get_nodes_in_group("enemies")
	var nearest: Node2D = null
	var nearest_dist := attack_range
	for e in enemies:
		var d := global_position.distance_to(e.global_position)
		if d < nearest_dist:
			nearest_dist = d
			nearest = e
	return nearest

func take_damage(amount: float) -> void:
	if shield_charges > 0:
		shield_charges -= 1
		return
	_flash_hit()
	health -= amount
	if health <= 0.0:
		health = 0.0
		GameManager.game_over()

func _flash_hit() -> void:
	if sprite == null:
		return
	sprite.modulate = Color(1.0, 0.3, 0.3)
	var tween := create_tween()
	tween.tween_property(sprite, "modulate", Color(1.0, 1.0, 1.0), 0.15)

func apply_lifesteal(enemy_max_health: float) -> void:
	if lifesteal_percent <= 0.0:
		return
	health = min(health + enemy_max_health * lifesteal_percent, max_health)

## --- Mejoras (llamadas desde LevelUpScreen.gd según lo que el jugador elija) ---

func apply_upgrade(id: String) -> void:
	match id:
		"fire_rate":
			fire_rate = max(0.08, fire_rate * 0.85)
		"damage":
			damage_multiplier += 0.25
		"projectile":
			projectile_count += 1
		"shield":
			shield_charges += 1
		"max_health":
			max_health += 20.0
			health = min(health + 20.0, max_health)
		"magnet":
			magnet_radius += 60.0
		"piercing":
			pierce_count += 1
		"lifesteal":
			lifesteal_percent += 0.08
