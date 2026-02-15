extends Node3D

@export var texturesToUse: Array[CompressedTexture2D]
@export var chanceToSpawn: float = 100

@export var bodyModel: MeshInstance3D

func _ready() -> void:
	await SignalBus.level_generation_finished
	if multiplayer.is_server():
		if !ZFunc.randInPercent(chanceToSpawn):
			delete_item.rpc()
		
		setup_body()


@rpc("authority", "call_local", "reliable")
func setup_body():
	if texturesToUse.size() > 0:
		var newmat := StandardMaterial3D
		newmat.albedo_texture = texturesToUse[ZFunc.rand_from(texturesToUse)]
		bodyModel.surface_material_override = newmat
	
	


@rpc("authority", "call_local", "reliable")
func delete_item():
	queue_free()
