extends Node

var scale = 0.01

func _ready():
	read_data(OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP), "TEST.ASC")

func generate_mesh(file_path, file_name):
	var ASC_data = read_data(file_path, file_name)
	
	var mesh_data = []
	mesh_data.resize(ArrayMesh.ARRAY_MAX)
	mesh_data[ArrayMesh.ARRAY_VERTEX] = PackedVector3Array(ASC_data["vertices"])
	mesh_data[ArrayMesh.ARRAY_INDEX] = PackedInt32Array(ASC_data["faces"])
	mesh_data[ArrayMesh.ARRAY_TEX_UV] = PackedVector2Array(ASC_data["uvs"])
	
	var mesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_data)
	
	var mdt = MeshDataTool.new()
	mdt.create_from_surface(mesh, 0)
	
	recalculate_normals(mdt)
	
	mesh.clear_surfaces()
	mdt.commit_to_surface(mesh)
	mdt.clear()
	
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = mesh
	
	mesh_instance.material_override = load("res://resources/head/head_material.tres")
	
	Global.main.add_child(mesh_instance)

func recalculate_normals(mesh_data_tool):
	for i in range(mesh_data_tool.get_face_count()):
		
		var a = mesh_data_tool.get_face_vertex(i, 0)
		var b = mesh_data_tool.get_face_vertex(i, 1)
		var c = mesh_data_tool.get_face_vertex(i, 2)
		
		var ap = mesh_data_tool.get_vertex(a)
		var bp = mesh_data_tool.get_vertex(b)
		var cp = mesh_data_tool.get_vertex(c)
		
		var n = (bp - cp).cross(ap - bp).normalized()
		
		mesh_data_tool.set_vertex_normal(a, n + mesh_data_tool.get_vertex_normal(a))
		mesh_data_tool.set_vertex_normal(b, n + mesh_data_tool.get_vertex_normal(b))
		mesh_data_tool.set_vertex_normal(c, n + mesh_data_tool.get_vertex_normal(c))

func read_data(file_path, file_name):
	var data = {
		"vertices" = [],
		"faces" = []
	}
	
	if not file_path.ends_with("/"):
		file_path = file_path + "/"
	var directory = file_path + file_name
	var file = FileAccess.open(directory, FileAccess.READ)
	var line = file.get_line()
	
	while not line.contains("MESH_VERTEX_LIST"):
		line = file.get_line()
	
	var vert_list = []
	line = file.get_line()
	if line.contains("MESH_VERTEX"):
		var _i = 0
		while not line.contains("}"):
			line = line.replace("\t\t\t*MESH_VERTEX ", "").split("\t")
			
			var vert = Vector3(float(line[1]), float(line[3]), float(line[2])) * scale
			vert_list.append(vert)
			
			line = file.get_line()
			_i += 1
	
	while not line.contains("MESH_FACE_LIST"):
		line = file.get_line()
	
	line = file.get_line()
	if line.contains("MESH_FACE"):
		var _i = 0
		while not line.contains("}"):
			line = line.replace("\t\t\t*MESH_FACE    " + str(_i) + ":", "").replace("    ", "").split(" ")
			line = [int(line[0].split(":")[1]), int(line[1].split(":")[1]), int(line[2].split(":")[1])]
			
			data["faces"].append({"vertices" = line})
			
			line = file.get_line()
			_i += 1
	
	while not line.contains("MESH_TVERTLIST"):
		line = file.get_line()
	
	var uv_list = []
	line = file.get_line()
	if line.contains("MESH_TVERT"):
		var _i = 0
		while not line.contains("}"):
			line = line.replace("\t\t\t*MESH_TVERT " + str(_i) + "\t", "").split("\t")
			
			var vert = Vector2(float(line[0]), float(line[1]))
			uv_list.append(vert)
			
			line = file.get_line()
			_i += 1
	
	while not line.contains("MESH_TFACELIST"):
		line = file.get_line()
	
	line = file.get_line()
	if line.contains("MESH_TFACE"):
		var _i = 0
		while not line.contains("}"):
			line = line.replace("\t\t\t*MESH_TFACE " + str(_i) + "\t", "").split("\t")
			line = [int(line[0]), int(line[1]), int(line[2])]
			
			data["faces"][_i]["vertices_uv"] = line
			
			line = file.get_line()
			_i += 1
	
	data["vertices"] = vert_list
	data["uvs"] = uv_list
	
	return data
