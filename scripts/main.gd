extends Node2D

var intersection_scene = load("res://scenes/intersection.tscn")

@onready var intersections_parent: Node = $Intersections

var intersection_list: Array[Intersection]

func _ready() -> void:
	MainData.CURRENT_MODE = MainData.modes.INTERSECTIONS

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if MainData.CURRENT_MODE == MainData.modes.INTERSECTIONS:
			var click_pos = get_global_mouse_position()

			for intersection in intersection_list:
				if intersection.position.distance_to(click_pos) <= 10.0:
					intersection_list.erase(intersection)
					intersection.queue_free()
					return

			var intersection_instance = intersection_scene.instantiate()
			intersection_instance.position = click_pos
			intersection_list.append(intersection_instance)
			intersections_parent.add_child(intersection_instance)
