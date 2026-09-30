extends Area2D

## Nodo: Area2D
## Hijos esperados: CollisionShape2D, un visual pequeño (ColorRect/Polygon2D/Sprite2D)

@export var speed: float = 500.0
@export var damage: float = 10.0
@export var lifetime: float = 2.0
@export var pierce: int = 0   # cuántos enemigos EXTRA puede atravesar (0 = se gasta en el primero)

var direction: Vector2 = Vector2.RIGHT
var _age: float = 0.0
var _hits: int = 0
var _hit_enemies: Array = []   # evita pegarle dos veces al mismo enemigo

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	rotation = direction.angle() + PI / 2.0   # el sprite apunta hacia arriba por defecto

func _process(delta: float) -> void:
	position += direction * speed * delta
	_age += delta
	if _age >= lifetime:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemies") and not _hit_enemies.has(area):
		if area.has_method("take_damage"):
			area.take_damage(damage)
		_hit_enemies.append(area)
		_hits += 1
		if _hits > pierce:
			queue_free()
