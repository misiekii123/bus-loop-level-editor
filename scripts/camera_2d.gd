extends Camera2D

const zoom_speed := 1.2
const pan_speed := 1.3
var zoom_factor = 1
var speed := 300.0

func _process(delta):
	position.x += Input.get_axis("move_left", "move_right") * speed * delta * 1/zoom.x
	position.y += Input.get_axis("move_up", "move_down") * speed * delta * 1/zoom.y
	queue_redraw()

func _unhandled_input(event):
	if (event is InputEventMouseButton) and !get_tree().paused:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom_factor *= zoom_speed
				zoom_factor = clamp(zoom_factor, 0.2, 5)
				zoom.x = zoom_factor
				zoom.y = zoom_factor 
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom_factor /= zoom_speed
				zoom_factor = clamp(zoom_factor, 0.2, 5)
				zoom.x = zoom_factor
				zoom.y = zoom_factor 
	if (event is InputEventMouseMotion) and !get_tree().paused:
		if event.button_mask == MOUSE_BUTTON_MASK_MIDDLE:
			position -= event.relative * 1/zoom.x * pan_speed
			
