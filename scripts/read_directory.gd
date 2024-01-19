extends Button

@onready var file_dialog: NativeFileDialog = get_node("file_dialog")
@onready var dir_label: Label = get_parent().get_node("background/text")

var shown = false

func _ready():
	file_dialog.connect("dir_selected", _dir_selected)
	file_dialog.connect("canceled", _canceled)

func _pressed():
	if not shown:
		file_dialog.show()
		shown = true

func _dir_selected(dir):
	dir = dir + "/"
	if get_parent().name.contains("output"):
		Global.texture_output_dir = dir
	elif get_parent().name.contains("assets"):
		Global.external_assets_dir = dir
		Global.initialize_external_data()
	dir_label.text = dir
	shown = false

func _canceled():
	shown = false
