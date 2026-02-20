extends Node3D

signal setup_finished

@export var texturesToUse: Array[CompressedTexture2D]
@export var chanceToSpawn: float = 100

@export var bodyModel: MeshInstance3D

func _ready() -> void:
	$body/AnimationPlayer.play("dead")
	
	await SignalBus.level_generation_finished
	if multiplayer.is_server():
		if !ZFunc.randInPercent(chanceToSpawn):
			delete_item.rpc()
			return
		
		setup_body()


@rpc("authority", "call_local", "reliable")
func setup_body():
	print("setting up body!")
	if texturesToUse.size() > 0:
		var newMat := StandardMaterial3D.new()
		newMat.albedo_texture = ZFunc.rand_from(texturesToUse)
		bodyModel.set_surface_override_material(0, newMat)
	
	setup_finished.emit()


@rpc("authority", "call_local", "reliable")
func delete_item():
	queue_free()
