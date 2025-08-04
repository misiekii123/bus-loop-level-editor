extends Node2D

var intersection_scene = load("res://scenes/intersection.tscn")
var edge_scene = load("res://scenes/edge.tscn")

@onready var intersections_parent: Node = $Intersections
@onready var edges_parent: Node = $Edges

@onready var generate_json_button = $CanvasLayer/EditorUI/VBoxContainer/GenerateJSONButton
@onready var load_json_button = $CanvasLayer/EditorUI/VBoxContainer/LoadJSONButton

var intersection_list: Array[Intersection]
var edges_list: Array[Edge]
var selected_intersection: Intersection = null

func _ready() -> void:
	MainData.CURRENT_MODE = MainData.modes.INTERSECTIONS
	generate_json_button.pressed.connect(on_generate_json_button_pressed)
	load_json_button.pressed.connect(on_load_json_button_pressed)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var click_pos = get_global_mouse_position()

		if MainData.CURRENT_MODE == MainData.modes.INTERSECTIONS:
			for intersection in intersection_list:
				if intersection.position.distance_to(click_pos) <= 10.0:
					intersection_list.erase(intersection)
					remove_edges_connected_to(intersection)
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
					handle_edge_click(intersection)
					return

func handle_edge_click(intersection: Intersection) -> void:
	if selected_intersection == null:
		selected_intersection = intersection
		selected_intersection.modulate = Color.YELLOW
	else:
		if selected_intersection == intersection:
			selected_intersection.modulate = Color.WHITE
			selected_intersection = null
			return

		var existing_edge := find_edge_between(selected_intersection, intersection)
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

func find_edge_between(a: Intersection, b: Intersection) -> Edge:
	for edge in edges_list:
		if (edge.intersection_a == a and edge.intersection_b == b) or (edge.intersection_a == b and edge.intersection_b == a):
			return edge
	return null

func remove_edges_connected_to(intersection: Intersection) -> void:
	var to_remove := []
	for edge in edges_list:
		if edge.intersection_a == intersection or edge.intersection_b == intersection:
			to_remove.append(edge)
	for edge in to_remove:
		edges_list.erase(edge)
		edge.queue_free()

func export_to_json_files() -> void:
	generate_nodes_json()
	generate_roads_json()

func generate_nodes_json() -> void:
	var nodes_data := {}
	for i in range(intersection_list.size()):
		var intersection = intersection_list[i]
		nodes_data[str(i + 1)] = {
			"x": intersection.position.x,
			"y": intersection.position.y
		}
	var file = FileAccess.open("user://nodes.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(nodes_data, "\t"))
	file.close()
	print("nodes.json saved to user://")

func generate_roads_json() -> void:
	var roads_data := {}
	var id_map := {}
	for i in range(intersection_list.size()):
		id_map[intersection_list[i]] = i + 1

	for i in range(edges_list.size()):
		var edge = edges_list[i]
		var node_a_id = id_map.get(edge.intersection_a, null)
		var node_b_id = id_map.get(edge.intersection_b, null)
		if node_a_id == null or node_b_id == null:
			continue

		roads_data[str(i + 1)] = {
			"node_a": node_a_id,
			"node_b": node_b_id,
			"buildings": []
		}
	var file = FileAccess.open("user://roads.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(roads_data, "\t"))
	file.close()
	print("roads.json saved to user://")

func on_generate_json_button_pressed() -> void:
	export_to_json_files()

func on_load_json_button_pressed() -> void:
	load_from_json_files()

func load_from_json_files() -> void:
	clear_scene()

	var nodes_file = FileAccess.open("user://nodes.json", FileAccess.READ)
	if nodes_file:
		var nodes_data = JSON.parse_string(nodes_file.get_as_text())
		nodes_file.close()

		for id in nodes_data.keys():
			var data = nodes_data[id]
			var intersection_instance: Intersection = intersection_scene.instantiate()
			intersection_instance.position = Vector2(data["x"], data["y"])
			intersections_parent.add_child(intersection_instance)
			intersection_list.append(intersection_instance)
			intersection_list.back().id = id

	var roads_file = FileAccess.open("user://roads.json", FileAccess.READ)
	if roads_file:
		var roads_data = JSON.parse_string(roads_file.get_as_text())
		roads_file.close()

		for id in roads_data.keys():
			var data = roads_data[id]
			var a_id = data["node_a"]
			var b_id = data["node_b"]
			
			var edge_instance: Edge = edge_scene.instantiate()
			edge_instance.intersection_a = look_for_intersection(a_id, b_id)[0]
			edge_instance.intersection_b = look_for_intersection(a_id, b_id)[1]
			edges_parent.add_child(edge_instance)
			edges_list.append(edge_instance)

	print("Data loaded from JSON.")

func look_for_intersection(a_id: int, b_id: int) -> Array[Intersection]:
	var result: Array[Intersection]
	for intersection in intersection_list:
		if intersection.id == a_id:
			result.append(intersection)
		if intersection.id == b_id:
			result.append(intersection)
	return result

func clear_scene() -> void:
	for intersection in intersection_list:
		intersection.queue_free()
	intersection_list.clear()

	for edge in edges_list:
		edge.queue_free()
	edges_list.clear()

	selected_intersection = null
