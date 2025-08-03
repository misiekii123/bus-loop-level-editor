extends Control

@onready var intersections_button = $VBoxContainer/IntersectionsButton
@onready var edges_button = $VBoxContainer/EdgesButton
@onready var generate_json_button = $VBoxContainer/GenerateJSONButtonButton

func _ready() -> void:
	intersections_button.button_pressed = true

func intersections_button_pressed():
	MainData.CURRENT_MODE = MainData.modes.INTERSECTIONS
	select_mode_buttons_unpress(0)

func edges_button_pressed():
	MainData.CURRENT_MODE = MainData.modes.EDGES
	select_mode_buttons_unpress(1)

func select_mode_buttons_unpress(skip: int):
	if skip != 0: intersections_button.button_pressed = false
	if skip != 1: edges_button.button_pressed = false
