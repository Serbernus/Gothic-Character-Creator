extends TabContainer

@onready var male_head_model = Global.main.get_node("male/skeleton/Skeleton3D/head_mesh")
@onready var female_head_model = Global.main.get_node("female/skeleton/Skeleton3D/head_mesh")

var head_model_dir = "res://resources/head/models/"
var body_model_dir = "res://resources/body/models/"

func _ready():
	connect("tab_selected", _select_gender)
	for node in get_children():
		var gender = node.name.to_lower()
		var option_panel = node.find_child("head_model").get_node("background/option")
		option_panel.connect("item_selected", _select_head_model.bind(gender))
		
		Global.head_models[gender] = []
		var file = gender + ".glb"
		var instance = load(head_model_dir + file).instantiate()
		var list = instance.get_children()
		list.reverse()
		for asset in list:
			var mesh = asset.mesh
			option_panel.add_item(asset.name.capitalize())
			Global.head_models[gender].append(mesh)

func _select_gender(tab):
	var gender = get_child(tab).name.to_lower()
	Global.s_gender = gender

func _select_head_model(index, gender):
	if gender == "male":
		male_head_model.mesh = Global.head_models[gender][index]
	if gender == "female":
		female_head_model.mesh = Global.head_models[gender][index]
