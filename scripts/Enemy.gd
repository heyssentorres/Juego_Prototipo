extends Area2D

## Nodo: Area2D (grupo "enemies")
## Hijos esperados: CollisionShape2D, un visual (ColorRect/Polygon2D/Sprite2D)
## Esta es la forma "base". Duplica esta escena y cambia solo estos valores
## (velocidad, vida, daño) para hacer al triángulo, cuadrado, círculo, etc.

@export var speed: float = 90.0
@export var max_health: float = 30.0
@export var contact_damage: float = 10.0
@export var contact_cooldown: float = 0.6
@export var score_value: int = 10
@export var xp_value: int = 5
@export var xp_orb_scene: PackedScene   # arrastra aquí XPOrb.tscn
@export var facing_offset_degrees: float = 0.0  # ajusta si el sprite no "mira" a la derecha

var health: float
var _player: Node2D
var _hit_timer: float = 0.0
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	health = max_health
	add_to_group("enemies")
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
