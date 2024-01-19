extends Node3D

@onready var male_char = get_node("male")
@onready var female_char = get_node("female")

var male_factor = 0.0
var female_factor = 0.0

@onready var display = find_child("display_container")
@onready var camera = display.get_node("display/gimbal/camera")
@onready var head = find_child("head_mesh")
@onready var gender_sections = find_child("gender_sections")

func _process(delta):
	Global.window_size = DisplayServer.window_get_size()
	Global.s_gender = gender_sections.get_child(gender_sections.current_tab).name.to_lower()
	
	if Global.s_gender == "male":
		male_factor = lerp(male_factor, 1.0, delta * 4)
		female_factor = lerp(female_factor, 0.0, delta * 4)
	elif Global.s_gender == "female":
		male_factor = lerp(male_factor, 0.0, delta * 4)
		female_factor = lerp(female_factor, 1.0, delta * 4)
	male_char.scale = Vector3.ONE * male_factor
	female_char.scale = Vector3.ONE * female_factor

func _input(event):
	if event is InputEventMouseMotion:
		Global.mouse_position = event.position
		Global.mouse_motion = event.relative
	if event is InputEventMouseButton:
		if event.is_action_pressed("mouse_left"):
			Global.click_left = true
		else:
			Global.click_left = false
		if event.is_action_pressed("mouse_right"):
			Global.click_right = true
		else:
			Global.click_right = false
