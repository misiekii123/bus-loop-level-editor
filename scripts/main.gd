extends Node2D

var intersection_scene = load("res://scenes/intersection.tscn")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var intersection_instance = intersection_scene.instantiate()
		intersection_instance.position = get_global_mouse_position()
		add_child(intersection_instance)
