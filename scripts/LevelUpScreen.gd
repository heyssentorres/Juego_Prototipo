extends CanvasLayer

## Nodo: CanvasLayer, Layer = 4 (por encima del HUD, por debajo del Game Over)
## Hijos esperados: ColorRect "Dim", Label "Title",
## Button "Slot1Button", Button "Slot2Button", Button "Slot3Button"
##
## Ya no hay una función fija por botón: cada vez que subes de nivel, se
## sortean 3 mejoras al azar del UPGRADE_POOL de Player.gd (sin repetir en
## esa misma oferta) y se les pone el texto y la acción correspondiente.

@onready var slot1_button: Button = $Slot1Button
@onready var slot2_button: Button = $Slot2Button
@onready var slot3_button: Button = $Slot3Button

var _buttons: Array[Button] = []
var _current_picks: Array = []

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS  # sigue activo aunque el juego esté en pausa
	visible = false
	_buttons = [slot1_button, slot2_button, slot3_button]
	for i in range(_buttons.size()):
		_buttons[i].pressed.connect(_on_button_pressed.bind(i))
	GameManager.level_up_triggered.connect(_on_level_up)

func _on_level_up() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player == null:
		return
	var pool: Array = player.UPGRADE_POOL.duplicate()
	pool.shuffle()
	_current_picks = pool.slice(0, _buttons.size())
	for i in range(_buttons.size()):
		if i < _current_picks.size():
			_buttons[i].text = _current_picks[i]["label"]
			_buttons[i].visible = true
		else:
			_buttons[i].visible = false  # por si el pool tuviera menos de 3 algún día
	visible = true
	get_tree().paused = true

func _on_button_pressed(index: int) -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player and index < _current_picks.size():
		player.apply_upgrade(_current_picks[index]["id"])
	visible = false
	get_tree().paused = false
