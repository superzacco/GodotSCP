extends Area3D

var ambiance: AmbienceManager

@export var spawnPoints: Array[Marker3D]
@export var releasePoints: Dictionary[PDReleasePoint, int]

@export var laugh: AudioStream

func _ready() -> void:
	ambiance = GlobalPlayerVariables.ambienceManager
	spawnPoints.append_array($SpawnPoints.get_children())
	
	SignalBus.send_player_to_106.connect(send_player_to_pd)
	SignalBus.setup_pd_release_point.connect(add_release_point)

func add_release_point(point: PDReleasePoint):
	print("Point: %s -- %s" % [point, point.weight])
	releasePoints[point] = point.weight


func send_player_to_pd(player: Player):
	var point: Marker3D = ZFunc.rand_from(spawnPoints)
	
	player.global_position = point.global_position
	player.stuffToRotate.global_rotation = point.global_rotation
	
	ambiance.play_sound(laugh)


func release_player_from_pd(player: Player):
	var point: Marker3D = ZFunc.pick_from_list(releasePoints)
	
	player.global_position = point.global_position
	player.stuffToRotate.global_rotation = point.global_rotation
	
	ambiance.play_sound(laugh)
	ZFunc.fade_out(ambiance.musicPlayerB, 5.0)


func _on_way_teleports_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		if ZFunc.randInPercent(50):
			send_player_to_pd(body)
		else:
			release_player_from_pd(body)


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		GlobalPlayerVariables.inPocketDimension = true

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		GlobalPlayerVariables.inPocketDimension = false
