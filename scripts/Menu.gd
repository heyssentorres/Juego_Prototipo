extends Control

## Nodo raiz: Control
## Hijos esperados: ColorRect "Background", Label "Title", Button "PlayButton"

@onready var play_button: Button = $PlayButton

func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)

func _on_play_pressed() -> void:
	GameManager.reset()
	get_tree().change_scene_to_file("res://scenes/Main.tscn")
