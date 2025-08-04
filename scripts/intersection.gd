extends Node2D

class_name Intersection

var id: int

func _draw() -> void:
	draw_circle(Vector2.ZERO, 10.0, Color.GRAY, true, -1.0, true)
