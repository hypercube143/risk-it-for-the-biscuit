extends Control

signal item_frame_buy_button_pressed

var bundle_id

func _on_buy_button_pressed() -> void:
	emit_signal("item_frame_buy_button_pressed", bundle_id)
