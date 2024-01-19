extends Button

var directory = ""

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Global.texture_output_dir == "":
		directory = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP) + "/"
	else:
		directory = Global.texture_output_dir

func _pressed():
	var texture = Global.main.find_child("head_mesh").material_override.albedo_texture
	var image = texture.get_image()
	var index = 0
	while FileAccess.file_exists(directory + "output_" + str(index) + ".png"):
		index += 1
	image.save_png(directory + "output_" + str(index) + ".png")
