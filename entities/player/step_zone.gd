extends Area3D

@export var ray: RayCast3D

#func _ready() -> void:
	#$Check.connect("timeout", process_fifth)


func process_fifth():
	return
	
	var col: StaticBody3D = ray.get_collider()
	
	if col != null:
		var colParent = col.get_parent()
		if colParent is MeshInstance3D:
			
			var meshInstance: MeshInstance3D = colParent
			var mesh: Mesh = meshInstance.mesh
			var material: Material = mesh.surface_get_material(0)
			
			#print(material.albedo_texture.resource_path)
			var faceIdx = ray.get_collision_face_index()
			
			print(mesh)
