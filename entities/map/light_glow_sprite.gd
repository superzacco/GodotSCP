extends Sprite3D

var playerCam: Camera3D = null

func _ready() -> void:
	await SignalBus.level_generation_finished
	transparency = 0.4
	playerCam = GlobalPlayerVariables.player.camera


func _physics_process(delta: float) -> void:
	if GlobalPlayerVariables.playerPosition.distance_to(self.global_position) > 20:
		if visible:
			hide()
		return
	
	if can_ray_see_player_camera():
		show()
	else:
		hide()


func can_ray_see_player_camera() -> bool:
	if playerCam == null:
		return false
	
	var resultNode: Node3D = ZFunc.get_ray_collider(self.global_position, playerCam.global_position)
	
	if resultNode == null or !resultNode.is_in_group("player"):
		return false
	
	return true
