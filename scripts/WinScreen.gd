extends CanvasLayer

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_button_yes_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Level 1.tscn")


func _on_button_no_pressed() -> void:
	get_tree().quit()
