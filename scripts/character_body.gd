extends Node3D

@onready var body = $skeleton/Skeleton3D/body_mesh
@onready var head = $skeleton/Skeleton3D/head_mesh
@onready var skeleton = $skeleton/Skeleton3D
@onready var animation = $AnimationPlayer
@onready var head_attachment = $skeleton/Skeleton3D/head_attachment

var bone_attach: BoneAttachment3D

var gender = ""

var s_skin_preset = ""
var s_hair_preset = ""
var force_update = false

var local_data = {
	"head" = {},
	"body" = {}
}

func _ready():
	gender = name
	for asset in Global.assets[gender]["head"]["data"]:
		local_data["head"][asset] = -2
	for asset in Global.assets[gender]["body"]["data"]:
		local_data["body"][asset] = -2

func _process(_delta):
	if not animation.is_playing():
		animation.play("stand")
	head.position = head_attachment.position
	head.rotation = head_attachment.rotation + Vector3(0, deg_to_rad(90), 0)
	if not s_skin_preset == Global.s_skin_preset or not s_hair_preset == Global.s_hair_preset:
		s_skin_preset = Global.s_skin_preset
		s_hair_preset = Global.s_hair_preset
		force_update = true
	set_texture_asset()

func set_texture_asset():
	for part in Global.assets[gender]:
		var output_mesh = Global.main.get_node("display_" + gender + "_" + part + "/camera/mesh")
		for asset in Global.assets[gender][part]["asset"]:
			if not local_data[part][asset] == Global.assets[gender][part]["data"][asset] or force_update:
				local_data[part][asset] = Global.assets[gender][part]["data"][asset]
				var data = Global.assets[gender][part]["data"][asset]
				if Global.assets[gender][part]["asset"][asset].size() > 0:
					var texture = Global.assets[gender][part]["asset"][asset][data]
					output_mesh.material_override.set_shader_parameter(asset, texture)
					var resource = load("res://resources/assets/base_null.png")
					if asset == "hair" or asset == "beard" or asset == "brows":
						resource = load("res://resources/gradients/hair/preset/" + Global.s_hair_preset + ".tres")
						output_mesh.material_override.set_shader_parameter(asset + "_r", resource)
					else:
						resource = load("res://resources/gradients/base/preset/" + Global.s_skin_preset + ".tres")
						output_mesh.material_override.set_shader_parameter(asset + "_r", resource)
					var dir_check = DirAccess.dir_exists_absolute("res://resources/gradients/" + asset + "/")
					var g_texture = GradientTexture1D.new()
					var gradient = Gradient.new()
					g_texture.gradient = gradient
					var resource_g = g_texture
					var resource_b = g_texture
					if dir_check:
						var channels = ["_g", "_b"]
						var path = "res://resources/gradients/" + asset + "/" + asset
						for channel in channels:
							var check_o = FileAccess.file_exists(path + channel + ".tres")
							var check_r = FileAccess.file_exists(path + channel + ".tres.remap")
							if check_o or check_r:
								resource = load(path + channel + ".tres")
							output_mesh.material_override.set_shader_parameter(asset + channel, resource)
					else:
						output_mesh.material_override.set_shader_parameter(asset + "_g", resource_g)
						output_mesh.material_override.set_shader_parameter(asset + "_b", resource_b)
	force_update = false
