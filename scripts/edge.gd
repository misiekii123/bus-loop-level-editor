extends Line2D

class_name Edge

var node_a: int
var node_b: int

var intersection_a: Intersection
var intersection_b: Intersection

func _draw() -> void:
	z_index = -1
	draw_line(intersection_a.position, intersection_b.position, Color.LIGHT_GRAY, 5.0, true)
