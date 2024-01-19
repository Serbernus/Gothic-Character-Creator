extends VBoxContainer

@onready var title_name = get_node("name")
@onready var asset_name = get_node("container/text_box/name")
@onready var display = get_node("container/button_assets/container/aspect/display")
@onready var asset_grid = get_node("popup_assets/background/scroll/container/grid")

var index_data = -2

var gender = ""
var part = ""

func _ready():
	title_name.text = name.capitalize()
	custom_minimum_size.x = 0
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var content = load("res://scenes/assets_option_content.tscn")
	for asset in Global.assets[gender][part]["asset"][name]:
		var instance = content.instantiate()
		
		instance.custom_minimum_size.x = 0
		instance.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		instance.name = asset.resource_name.split(".")[0]
		instance.get_node("name").text = asset.resource_name.split(".")[0]
		instance.connect("pressed", _option_selected.bind(instance))
		
		var texture = asset
		var texture_size = texture.get_size()
		if texture_size.x == texture_size.y:
			var aspect = instance.get_node("aspect")
			aspect.ratio = 1
		var content_display = instance.get_node("aspect/display")
		var mat: ShaderMaterial = content_display.material.duplicate()
		mat.set_shader_parameter("image", texture)
		content_display.material = mat
		asset_grid.add_child(instance)

func _process(_delta):
	if not index_data == Global.assets[gender][part]["data"][name]:
		index_data = Global.assets[gender][part]["data"][name]
		var texture = load("res://resources/assets/base_null.png")
		if index_data == -1:
			asset_name.text = "Empty"
			display.material.set_shader_parameter("image", texture)
		elif Global.assets[gender][part]["asset"][name].size() > 0:
			var asset = Global.assets[gender][part]["asset"][name][index_data]
			asset_name.text = asset.resource_name.split(".")[0].capitalize()
			texture = asset
			var texture_size = texture.get_size()
			if texture_size.x == texture_size.y:
				var aspect = display.get_parent()
				aspect.ratio = 1
			display.material.set_shader_parameter("image", texture)

func _option_selected(node):
	Global.assets[gender][part]["data"][name] = node.get_index()
