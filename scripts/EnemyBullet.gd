extends Area2D

## Nodo: Area2D
## Hijos esperados: CollisionShape2D, un visual (Polygon2D placeholder por ahora
## — cuando tengan arte para este proyectil, se reemplaza igual que el del jugador)

@export var speed: float = 260.0
@export var damage: float = 8.0
@export var lifetime: float = 3.0

var direction: Vector2 = Vector2.RIGHT
var _age: float = 0.0

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	rotation = direction.angle()

func _process(delta: float) -> void:
	position += direction * speed * delta
	_age += delta
	if _age >= lifetime:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		if area.has_method("take_damage"):
			area.take_damage(damage)
		queue_free()
