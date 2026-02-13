extends Area3D

@export var spawnPoints: Array[Marker3D]
@export var releasePoints: Dictionary[PDReleasePoint, int]

func _ready() -> void:
	spawnPoints.append_array($SpawnPoints.get_children())
	
	SignalBus.send_player_to_106.connect(send_player_to_pd)
	SignalBus.setup_pd_release_point.connect(add_release_point)

func add_release_point(point: PDReleasePoint):
	#print("Point: %s -- %s" % [point, point.weight])
	releasePoints[point] = point.weight


func send_player_to_pd(player: Player):
	var point: Marker3D = ZFunc.rand_from(spawnPoints)
	
	player.global_position = point.global_position
	player.stuffToRotate.global_rotation = point.global_rotation
	
	$Audio/Laugh.play()
	
	if !$Audio/PDAmbiance.playing:
		ZFunc.fade_in($Audio/PDAmbiance, 3.0)
		$Audio/PDAmbiance.play()


func release_player_from_pd(player: Player):
	var point: Marker3D = ZFunc.pick_from_list(releasePoints)
	
	player.global_position = point.global_position
	player.stuffToRotate.global_rotation = point.global_rotation
	
	$Audio/Laugh.play()
	ZFunc.fade_out($Audio/PDAmbiance, 8.0)


func _on_way_teleports_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		if ZFunc.randInPercent(40):
			send_player_to_pd(body)
		else:
			release_player_from_pd(body)


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		GlobalPlayerVariables.inPocketDimension = true

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		GlobalPlayerVariables.inPocketDimension = false
