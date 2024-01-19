extends Control

@onready var selector_prefab = load("res://scenes/gradient_selector.tscn")
@onready var color_picker = Global.main.find_child("color_picker")

var init = true
var delay = 0

var common_gradients = []
var asset_gradients = []

var container_size_x = 0

var controlls_size = Global.controlls_size
var s_skin_preset = Global.s_skin_preset
var s_hair_preset = Global.s_hair_preset
var s_part = Global.s_part

var mouse_position:Vector2i
var window_size:Vector2i

var current_selector = null
var current_gradient = null
var c_left = false
var c_right = false
var dc_left = false
var dc_right = false

func _ready():
	common_gradients = find_child("common_gradients").get_children()
	for gradient in common_gradients:
		var container = gradient.get_node("texture")
		if gradient.name.contains("base"):
			container.texture = load("res://resources/gradients/base/preset/" + Global.s_skin_preset + ".tres")
		elif gradient.name.contains("hair"):
			container.texture = load("res://resources/gradients/hair/preset/" + Global.s_hair_preset + ".tres")
		container.connect("gui_input", _gradient_input.bind(container))
		container.connect("mouse_exited", _mouse_gradient_exited)
	
	var tmp_array = []
	for part in find_child("part_section").get_children():
		asset_gradients = part.find_child("assets").get_children()
		for asset in asset_gradients:
			for gradient in asset.find_child("popup_gradients").find_children("gradient"):
				tmp_array.append(gradient)
				var container = gradient.get_node("texture")
				var channel = str(gradient.get_parent().name)[0]
				var path_o = "res://resources/gradients/" + asset.name + "/" + asset.name + "_" + channel + ".tres"
				var path_r = "res://resources/gradients/" + asset.name + "/" + asset.name + "_" + channel + ".tres.remap"
				if FileAccess.file_exists(path_o) or FileAccess.file_exists(path_r):
					var texture = load(path_o)
					container.texture = texture
				else:
					var texture = GradientTexture1D.new()
					texture.gradient = Gradient.new()
					container.texture = texture
				container.connect("gui_input", _gradient_input.bind(container))
				container.connect("mouse_exited", _mouse_gradient_exited)
	asset_gradients = tmp_array

func _process(_delta):	
	if not visible:
		init = true
		delay = 0
	elif not controlls_size == Global.controlls_size or not s_part == Global.s_part:
		s_part = Global.s_part
		controlls_size = Global.controlls_size
		for gradient in common_gradients:
			var container = gradient.get_node("texture")
			for selector in container.get_children():
				selector.free()
		for gradient in asset_gradients:
			var container = gradient.get_node("texture")
			for selector in container.get_children():
				selector.free()
		init = true
		delay = 0
	elif not s_skin_preset == Global.s_skin_preset or not s_hair_preset == Global.s_hair_preset:
		s_skin_preset = Global.s_skin_preset
		s_hair_preset = Global.s_hair_preset
		for gradient in common_gradients:
			var container = gradient.get_node("texture")
			if gradient.name.contains("base"):
				container.texture = load("res://resources/gradients/base/preset/" + Global.s_skin_preset + ".tres")
				var size_x = Global.controlls_size - 40
				initialize_selectors(container, size_x)
			elif gradient.name.contains("hair"):
				container.texture = load("res://resources/gradients/hair/preset/" + Global.s_hair_preset + ".tres")
				var size_x = Global.controlls_size - 40
				initialize_selectors(container, size_x)
	elif visible and init:
		if delay == 1:
			for gradient in common_gradients:
				var container = gradient.get_node("texture")
				var size_x = Global.controlls_size - 40
				initialize_selectors(container, size_x)
			for gradient in asset_gradients:
				var container = gradient.get_node("texture")
				var size_x = Global.controlls_size - 140
				initialize_selectors(container, size_x)
			init = false
		else:
			delay += 1
	elif visible and not init:
		if current_selector and c_right:
			current_selector.free()
			c_right = false
		elif current_selector and c_left:
			var container = current_gradient
			var selector_position = mouse_position.x
			selector_position = clamp(selector_position, 5, round(container.size.x / 5) * 5 - 5)
			current_selector.position.x = selector_position
			var index = current_selector.get_index()
			if not index == container.get_children().size() - 1:
				var next_sel = container.get_child(index + 1)
				if current_selector.position.x > next_sel.position.x:
					container.move_child(current_selector, index + 1)
			if not index == 0:
				var prev_sel = container.get_child(index - 1)
				if current_selector.position.x < prev_sel.position.x:
					container.move_child(current_selector, index - 1)
		
		if current_gradient and dc_left and not current_selector:
			instantiate_selector(mouse_position, current_gradient, selector_prefab)
			dc_left = false
		elif current_selector and dc_left:
			color_picker.current_selector = current_selector
			color_picker.current_gradient = current_gradient
			c_left = false
			dc_left = false
		if current_gradient:
			var gradient = Gradient.new()
			var gradient_data = {}
			for selector in current_gradient.get_children():
				var factor = (selector.position.x - 5) / (current_gradient.size.x - 10)
				var color = selector.get_node("button/color_real").color
				selector.get_node("button/color").color = color + Color.WHITE * 0.25
				gradient_data[factor] = color
			gradient.offsets = gradient_data.keys()
			gradient.colors = gradient_data.values()
			current_gradient.texture.gradient = gradient

func initialize_selectors(container, size_x):
	for selector in container.get_children():
		selector.free()
	var source_gradient = container.texture.gradient
	for index in source_gradient.get_point_count():
		var selector = selector_prefab.instantiate()
		var offset = clamp(source_gradient.get_offset(index), 0, 1)
		var selector_position = offset * (size_x - 10) + 5.0
		selector.position.x = selector_position
		selector.size.y = 60
		
		var color = source_gradient.get_color(index)
		selector.get_node("button/color").color = color + Color.WHITE * 0.25
		selector.get_node("button/color_real").color = color
		
		selector.get_node("button").connect("gui_input", _selector_input.bind(selector))
		selector.get_node("button").connect("mouse_exited", _mouse_selector_exited)
			
		container.add_child(selector)

func instantiate_selector(m_pos, c_gradient, prefab):
	var gradient: Gradient = c_gradient.texture.gradient
	var factor = m_pos.x / c_gradient.size.x
	var color = gradient.sample(factor)
	
	var selector = prefab.instantiate()
	
	selector.position.x = m_pos.x
	selector.get_node("button/color").color = color + Color.WHITE * 0.25
	selector.get_node("button/color_real").color = color
	
	selector.get_node("button").connect("gui_input", _selector_input.bind(selector))
	selector.get_node("button").connect("mouse_exited", _mouse_selector_exited)
	
	c_gradient.add_child(selector)
	
	for i in c_gradient.get_children().size() - 1:
		var child_f = c_gradient.get_child(i).position.x / c_gradient.size.x
		if child_f > factor:
			c_gradient.move_child(c_gradient.get_child(selector.get_index()), i)
			break

func _mouse_gradient_exited():
	current_gradient = null

func _mouse_selector_exited():
	current_selector = null

func _gradient_input(event, container):
	if not current_gradient == container:
		current_gradient = container
	if event is InputEventMouseButton:
		if event.is_action_pressed("mouse_left"):
			c_left = true
			if event.double_click:
				dc_left = true
		elif event.is_action_released("mouse_left"):
			c_left = false
			dc_left = false
		if event.is_action_pressed("mouse_right"):
			c_right = true
		elif event.is_action_released("mouse_right"):
			c_right = false
	if event is InputEventMouseMotion:
		mouse_position = event.position

func _selector_input(_event, selector):
	if not current_selector == selector:
		current_selector = selector

func _asset_button_pressed(node):
	var container = find_child("assets")
	for asset in container.get_children():
		var button_assets = asset.find_child("button_assets")
		var button_gradients = asset.find_child("button_gradients")
		if not button_assets == node and not button_gradients == node:
			button_assets.showing = false
			button_gradients.showing = false
