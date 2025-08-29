extends Node2D

var current_scene

func _ready() -> void:
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count()-1)

func switch_scene(path):
	call_deferred("_deferred_switch_scene", path)

func _deferred_switch_scene(path):
	current_scene.free()
	var s = load(path)
	current_scene = s.instantiate()
	get_tree().root.add_child(current_scene)
	get_tree().current_scene = current_scene

func _process(_delta: float) -> void:
	if Input.is_action_just_released('escape'):
		get_tree().quit()
