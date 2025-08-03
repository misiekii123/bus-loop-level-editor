extends Node2D

var intersection_scene = load("res://scenes/intersection.tscn")
var edge_scene = load("res://scenes/edge.tscn")

@onready var intersections_parent: Node = $Intersections
@onready var edges_parent: Node = $Edges

var intersection_list: Array[Intersection]
var edges_list: Array[Edge]
var selected_intersection: Intersection = null

func _ready() -> void:
	MainData.CURRENT_MODE = MainData.modes.INTERSECTIONS

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var click_pos = get_global_mouse_position()

		if MainData.CURRENT_MODE == MainData.modes.INTERSECTIONS:
			for intersection in intersection_list:
				if intersection.position.distance_to(click_pos) <= 10.0:
					intersection_list.erase(intersection)
					_remove_edges_connected_to(intersection)
					intersection.queue_free()
					if intersection == selected_intersection:
						selected_intersection = null
					return

			var intersection_instance = intersection_scene.instantiate()
			intersection_instance.position = click_pos
			intersection_list.append(intersection_instance)
			intersections_parent.add_child(intersection_instance)

		elif MainData.CURRENT_MODE == MainData.modes.EDGES:
			for intersection in intersection_list:
				if intersection.position.distance_to(click_pos) <= 10.0:
					_handle_edge_click(intersection)
					return

func _handle_edge_click(intersection: Intersection) -> void:
	if selected_intersection == null:
		selected_intersection = intersection
		selected_intersection.modulate = Color.YELLOW
	else:
		if selected_intersection == intersection:
			selected_intersection.modulate = Color.WHITE
			selected_intersection = null
			return

		var existing_edge := _find_edge_between(selected_intersection, intersection)
		if existing_edge:
			edges_list.erase(existing_edge)
			existing_edge.queue_free()
		else:
			var edge_instance: Edge = edge_scene.instantiate()
			edge_instance.intersection_a = selected_intersection
			edge_instance.intersection_b = intersection
			edges_list.append(edge_instance)
			edges_parent.add_child(edge_instance)

		selected_intersection.modulate = Color.WHITE
		selected_intersection = null

func _find_edge_between(a: Intersection, b: Intersection) -> Edge:
	for edge in edges_list:
		if (edge.intersection_a == a and edge.intersection_b == b) or (edge.intersection_a == b and edge.intersection_b == a):
			return edge
	return null

func _remove_edges_connected_to(intersection: Intersection) -> void:
	var to_remove := []
	for edge in edges_list:
		if edge.intersection_a == intersection or edge.intersection_b == intersection:
			to_remove.append(edge)
	for edge in to_remove:
		edges_list.erase(edge)
		edge.queue_free()
