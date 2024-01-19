extends Window
@onready var picker:ColorPicker = get_node("picker")

var current_gradient = null
var current_selector = null
var init = true

func _process(_delta):
	if not visible and not init:
		init = true
		current_selector = null
	if not visible and current_selector:
		var color = current_selector.get_node("button/color_real").color
		picker.color = color
		if init:
			var window_size = Global.window_size
			var pos = current_selector.global_position + current_selector.size
			pos.x = clamp(pos.x, 0, window_size.x - size.x)
			pos.y = clamp(pos.y, 0, window_size.y - size.y)
			position = pos
			visible = true
			init = false
	if visible and current_selector:
		var color = picker.color
		current_selector.get_node("button/color_real").color = color
		var gradient = Gradient.new()
		var gradient_data = {}
		for selector in current_gradient.get_children():
			var factor = (selector.position.x - 5) / (current_gradient.size.x - 10)
			color = selector.get_node("button/color_real").color
			selector.get_node("button/color").color = color + Color.WHITE * 0.25
			gradient_data[factor] = color
		gradient.offsets = gradient_data.keys()
		gradient.colors = gradient_data.values()
		current_gradient.texture.gradient = gradient
