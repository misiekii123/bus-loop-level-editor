extends Node2D

enum modes {
	INTERSECTIONS,
	EDGES
}

var current_mode: modes

var intersection_scene = load("res://scenes/intersection.tscn")

@onready var intersections_parent: Node = $Intersections

var intersection_list: Array[Intersection]

func _ready() -> void:
	current_mode = modes.INTERSECTIONS

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if current_mode == modes.INTERSECTIONS:
			var intersection_instance = intersection_scene.instantiate()
			intersection_instance.position = get_global_mouse_position()
			intersection_list.append(intersection_instance)
			intersections_parent.add_child(intersection_instance)
