extends Node

@onready var main = $/root/main

var window_size: Vector2i
var mouse_position: Vector2i
var mouse_motion: Vector2i

var controlls_size = 800

var click_left = false
var click_right = false

const assets_order = {
	"head" = [
		"base",
		"eyes",
		"nose",
		"mouth",
		"ears"
	],
	"body" = [
		"base",
		"chest",
		"arms",
		"hands",
		"legs",
		"feets"
	]
}

var texture_output_dir: String = ""
var external_assets_dir: String = ""
var internal_assets_dir: String = "res://resources/assets/"
var assets: Dictionary = {}

var head_models = {}

var s_resolution = 0
var s_skin_preset = "white"
var s_hair_preset = "dark"
var s_gender = "male"
var s_part = "head"

func _ready():
	texture_output_dir = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP) + "/"
	initialize_data(internal_assets_dir)
	initialize_genders_ui()
	initialize_assets_ui()
	initialize_shader()

func initialize_data(directory):
	var main_dir = DirAccess.get_directories_at(directory)
	main_dir.reverse()
	for gender in main_dir:
		if gender == "male" or gender == "female":
			if directory == internal_assets_dir:
				assets[gender] = {}
			var gender_dir = DirAccess.get_directories_at(directory + gender + "/")
			for part in gender_dir:
				if part == "head" or part == "body":
					if directory == internal_assets_dir:
						assets[gender][part] = {}
						assets[gender][part]["data"] = {}
						assets[gender][part]["asset"] = {}
					for asset in assets_order[part]:
						var path = directory + gender + "/" + part + "/" + asset + "/"
						if DirAccess.dir_exists_absolute(path):
							var files = DirAccess.get_files_at(path)
							if not files.size() == 0:
								if directory == internal_assets_dir:
									assets[gender][part]["data"][asset] = 0
									assets[gender][part]["asset"][asset] = []
									for file in files:
										if file.ends_with(".import"):
											var texture = load(path + file.replace(".import", ""))
											texture.resource_name = file.replace(".import", "")
											assets[gender][part]["asset"][asset].append(texture)
								else:
									for file in files:
										var image = Image.load_from_file(path + file)
										var texture = ImageTexture.create_from_image(image)
										texture.resource_name = file
										assets[gender][part]["asset"][asset].append(texture)
							else:
								assets[gender][part]["data"][asset] = -1
								assets[gender][part]["asset"][asset] = []
					var part_dir = DirAccess.get_directories_at(directory + gender + "/" + part + "/")
					for asset in part_dir:
						if not assets_order[part].has(asset):
							var path = directory + gender + "/" + part + "/" + asset + "/"
							var files = DirAccess.get_files_at(path)
							if not files.size() == 0:
								if directory == internal_assets_dir:
									assets[gender][part]["data"][asset] = 0
									assets[gender][part]["asset"][asset] = []
									var texture = load("res://resources/assets/base_null.png")
									texture.resource_name = "empty"
									assets[gender][part]["asset"][asset].append(texture)
									for file in files:
										if file.ends_with(".import"):
											texture = load(path + file.replace(".import", ""))
											texture.resource_name = file.replace(".import", "")
											assets[gender][part]["asset"][asset].append(texture)
								else:
									if assets[gender][part]["asset"].has(asset):
										for file in files:
											var image = Image.load_from_file(path + file)
											var texture = ImageTexture.create_from_image(image)
											texture.resource_name = file
											assets[gender][part]["asset"][asset].append(texture)
									else:
										assets[gender][part]["data"][asset] = 0
										assets[gender][part]["asset"][asset] = []
										var texture = load("res://resources/assets/base_null.png")
										texture.resource_name = "empty"
										assets[gender][part]["asset"][asset].append(texture)
										for file in files:
											var image = Image.load_from_file(path + file)
											texture = ImageTexture.create_from_image(image)
											texture.resource_name = file
											assets[gender][part]["asset"][asset].append(texture)
							else:
								assets[gender][part]["data"][asset] = -1
								assets[gender][part]["asset"][asset] = []

func initialize_external_data():
	var gender_section = main.find_child("gender_sections")
	for genders in assets:
		var gender_node = gender_section.get_node(genders.capitalize())
		gender_node.free()
	assets = {}
	initialize_data(internal_assets_dir)
	initialize_data(external_assets_dir)
	initialize_genders_ui()
	initialize_assets_ui()
	initialize_shader()

func initialize_genders_ui():
	var gender_section = main.find_child("gender_sections")
	var panel = load("res://scenes/gender_section.tscn")
	var genders = assets.keys()
	for gender in genders:
		var instance = panel.instantiate()
		instance.name = gender.capitalize()
		gender_section.add_child(instance)
		instance.visible = true
	
func initialize_assets_ui():
	var gender_section = main.find_child("gender_sections")
	var panel = load("res://scenes/assets_option.tscn")
	var image = load("res://resources/assets/base_null.png")
	for gender in assets:
		var gender_container = gender_section.get_node(gender.capitalize())
		if gender_container:
			for part in assets[gender]:
				var assets_container = gender_container.find_child(part.capitalize()).find_child("assets")
				for asset in assets[gender][part]["asset"]:
					var instance: Node = panel.instantiate()
					instance.name = asset
					instance.gender = gender
					instance.part = part
					
					var button_assets = instance.get_node("container/button_assets")
					var button_gradients = instance.get_node("container/button_gradients")
					
					button_assets.connect("pressed", gender_container._asset_button_pressed.bind(button_assets))
					button_gradients.connect("pressed", gender_container._asset_button_pressed.bind(button_gradients))
					
					var display = instance.get_node("container/button_assets/container/aspect/display")
					var mat: ShaderMaterial = display.material.duplicate()
					mat.set_shader_parameter("image", image)
					display.material = mat
					
					assets_container.add_child(instance)

func initialize_shader():
	for gender in assets:
		for part in assets[gender]:
			var shader = Shader.new()
			var material = ShaderMaterial.new()
			var shader_type = "shader_type spatial;\n"
			var render_mode = "render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_lambert, specular_schlick_ggx;\n\n"
			
			var parameters = ""
			var parameter_line = "uniform sampler2D (tr) : source_color, hint_default_transparent, filter_nearest;\n"
			for asset in assets[gender][part]["asset"]:
				parameters += parameter_line.replace("(tr)", asset)
				parameters += parameter_line.replace("(tr)", asset + "_r")
				parameters += parameter_line.replace("(tr)", asset + "_g")
				parameters += parameter_line.replace("(tr)", asset + "_b")
			parameters += "\n"
			
			var fragment_start = "void fragment() {\n"
			
			var base_math = ""
			var base_line = "\tvec4 (tr)_color = texture((tr), UV);\n"
			var r_line = "\tvec4 (tr)_r_o = texture((tr)_r, vec2((tr)_color.xx));\n"
			var g_line = "\tvec4 (tr)_g_o = texture((tr)_g, vec2((tr)_color.yy));\n"
			var b_line = "\tvec4 (tr)_b_o = texture((tr)_b, vec2((tr)_color.zz));\n"
			var final_line = "\tvec3 (tr)_final = vec3((tr)_r_o.xyz + (tr)_g_o.xyz + (tr)_b_o.xyz);\n"
			for asset in assets[gender][part]["asset"]:
				var math_line = base_line + r_line + g_line + b_line + final_line
				base_math += math_line.replace("(tr)", asset) + "\n"
			
			var blend = ""
			var blend_line = "\tvec3 (tr)_blend = vec3((tr)_color.w, (tr)_color.w, (tr)_color.w);\n"
			var out_line = "\tvec3 (tr_1)_out = mix((tr_1)_final, (tr_2)_final, (tr_2)_blend);\n"
			var index = 0
			var keys = assets[gender][part]["asset"].keys()
			for asset in assets[gender][part]["asset"]:
				if not index == 0:
					if index == 1:
						var prev_asset = keys[index - 1]
						blend += blend_line.replace("(tr)", asset)
						blend += out_line.replace("(tr_1)", prev_asset).replace("(tr_2)", asset) + "\n"
					else:
						var prev_asset = keys[index - 1]
						var prev_prev_asset = keys[index - 2]
						out_line = "\tvec3 (tr_1)_out = mix((tr_3)_out, (tr_2)_final, (tr_2)_blend);\n"
						if index == assets[gender][part]["asset"].size() - 1:
							out_line = "\tvec3 final = mix((tr_3)_out, (tr_2)_final, (tr_2)_blend);\n"
						blend += blend_line.replace("(tr)", asset)
						blend += out_line.replace("(tr_1)", prev_asset).replace("(tr_2)", asset).replace("(tr_3)", prev_prev_asset) + "\n"
				index += 1
			
			var fragment_end = "\tALBEDO = final;\n}"
			var output = shader_type + render_mode + parameters + fragment_start + base_math + blend + fragment_end
			
			shader.code = output
			material.shader = shader
			main.get_node("display_" + gender + "_" + part + "/camera/mesh").material_override = material

func randomize_index_data():
	for data in assets[s_gender][s_part]["data"]:
		var size = assets[s_gender][s_part]["asset"][data].size() - 1
		if not size == 0:
			var num = assets[s_gender][s_part]["data"][data]
			while num == assets[s_gender][s_part]["data"][data]:
				num = randi_range(0, size)
			assets[s_gender][s_part]["data"][data] = num
