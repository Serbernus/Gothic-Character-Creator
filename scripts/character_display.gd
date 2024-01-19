extends SubViewportContainer

@onready var gimbal = $display/gimbal
@onready var camera = $display/gimbal/camera
@onready var counter = $counter

var camera_distance = 1.5
var camera_distance_clamp = [1.0, 6.0]

var camera_position = Vector3(0, 0, 0)
var camera_position_clamp = [1.0, 1.65]

var camera_rotation = Vector3(0, 0, 0)
var camera_offset = Vector3(0, 0, 0)

var mouse_position = Vector2(0, 0)
var mouse_motion = Vector2(0, 0)

var click_left = false
var double_click_left = false
var click_right = false
var double_click_right = false

func _ready():
	camera_rotation = Vector3(0, deg_to_rad(-20), 0)
	counter.size = Vector2i(80, 30)
	counter.position = Vector2i(5, 5)

func _process(delta):
	if Global.s_gender == "male":
		camera_position.x = 0
	elif Global.s_gender == "female":
		camera_position.x = 2
	
	if click_left or click_right:
		camera_rotation -= Vector3(mouse_motion.y, mouse_motion.x, 0) * delta
	camera_rotation.x = clamp(camera_rotation.x, deg_to_rad(-70), deg_to_rad(40))
	
	var camera_distance_factor = (camera_distance - 1) / camera_distance_clamp[1]
	camera_position.y = lerp(camera_position_clamp[1], camera_position_clamp[0], camera_distance_factor)
	
	camera.position.z = lerp(camera.position.z, camera_distance, delta * 4)
	gimbal.position = lerp(gimbal.position, camera_position + camera_offset, delta * 4)
	gimbal.rotation = lerp(gimbal.rotation, camera_rotation, delta * 4)
	
	counter.get_node("fps").text = str(Engine.get_frames_per_second())
	
	mouse_motion = Vector2(0, 0)

func _gui_input(event):
	if event is InputEventMouseMotion:
		mouse_position = event.position
		mouse_motion = event.relative
	
	if event is InputEventMouseButton:
		if event.is_action_pressed("mouse_left"):
			click_left = true
			if event.double_click:
				double_click_left = true
		else:
			click_left = false
		
		if event.is_action_pressed("mouse_right"):
			click_right = true
			if event.double_click:
				double_click_right = true
		else:
			click_right = false
		
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera_distance -= 0.25
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera_distance += 0.25
		camera_distance = clamp(camera_distance, camera_distance_clamp[0], camera_distance_clamp[1])
