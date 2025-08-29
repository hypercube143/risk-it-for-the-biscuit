extends Control


func _on_start_button_pressed() -> void:
	Controller.switch_scene("scenes/tutorial.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
