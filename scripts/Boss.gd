extends Area2D

## Nodo: Area2D (grupos "enemies" y "boss")
## Hijos esperados: CollisionShape2D, Polygon2D (visual, hexágono grande)
## Reutiliza la misma lógica de persecución/contacto que Enemy.gd, pero
## mucho más resistente, y su muerte dispara la victoria en vez de solo puntos.

@export var speed: float = 60.0
@export var max_health: float = 400.0
@export var contact_damage: float = 20.0
@export var contact_cooldown: float = 0.6
@export var score_value: int = 200
@export var facing_offset_degrees: float = 90.0  # el sprite mira hacia arriba por defecto

var health: float
var _player: Node2D
var _hit_timer: float = 0.0
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	health = max_health
	add_to_group("enemies")   # así el jugador lo detecta como blanco y las balas le pegan
	add_to_group("boss")
	_player = get_tree().get_first_node_in_group("player")
	area_entered.connect(_on_area_entered)

func _process(delta: float) -> void:
	if is_instance_valid(_player):
		var dir := (_player.global_position - global_position).normalized()
		position += dir * speed * delta
		rotation = dir.angle() + deg_to_rad(facing_offset_degrees)
	_hit_timer -= delta

func take_damage(amount: float) -> void:
	_flash_hit()
	health -= amount
	if health <= 0.0:
		GameManager.add_score(score_value)
		GameManager.notify_enemy_killed(max_health)
		GameManager.victory()
		queue_free()

func _flash_hit() -> void:
	if sprite == null:
		return
	sprite.modulate = Color(1.0, 0.3, 0.3)
	var tween := create_tween()
	tween.tween_property(sprite, "modulate", Color(1.0, 1.0, 1.0), 0.15)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player") and _hit_timer <= 0.0:
		if area.has_method("take_damage"):
			area.take_damage(contact_damage)
		_hit_timer = contact_cooldown
