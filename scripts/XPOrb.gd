extends Area2D

## Nodo: Area2D (grupo "xp_orbs")
## Hijos esperados: CollisionShape2D (círculo pequeño), Polygon2D (visual)

@export var xp_value: int = 5
@export var magnet_speed: float = 420.0   # qué tan rápido vuela hacia el jugador si está en rango

var _player: Node2D

func _ready() -> void:
	add_to_group("xp_orbs")
	area_entered.connect(_on_area_entered)
	_player = get_tree().get_first_node_in_group("player")

func _process(delta: float) -> void:
	if not is_instance_valid(_player):
		return
	var magnet_radius: float = 0.0
	if "magnet_radius" in _player:
		magnet_radius = _player.magnet_radius
	if magnet_radius <= 0.0:
		return
	if global_position.distance_to(_player.global_position) <= magnet_radius:
		var dir := (_player.global_position - global_position).normalized()
		position += dir * magnet_speed * delta

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		GameManager.add_xp(xp_value)
		queue_free()
