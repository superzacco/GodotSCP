extends CharacterBody3D

@export var enabled: bool = false

@export var speed: float
@export var agent: NavigationAgent3D

@export var tooCloseToPlayers: float 
@export var tooFarFromPlayers: float 
@export var breakDoorChance: float

@export var relocateTimer: Timer
@export var processTimer: Timer
@export var visuallyObscuredMarkers: Array[Marker3D]
@export var stoneScrapingPlayer: AudioStreamPlayer3D
@export var neckSnapSounds: Array[AudioStream]
@export var relocationSounds: Array[AudioStream]

var playersState := {} # // playerID ---> {91829382 : {"visible": onScreen, "blinking": blinking}}
var playersInRadius: Array[Player]
var nearPlayer: bool = false
var relocating: bool = false

var playersInKillRange: Array[Player] = []
var nearDoor: Door 

func _on_visible_on_screen_notifier_3d_screen_entered() -> void:
	pass
func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
	pass


func _ready() -> void:
	SignalBus.teleport_173_to_player.connect(teleport_to_player)
	SignalBus.activate_173.connect(try_relocate)
	SignalBus.relocate_173.connect(try_relocate)
	
	processTimer.timeout.connect(process_one)


var nextPathPos := Vector3.ZERO
func process_one():
	process_client()
	process_server()
	
	if GlobalPlayerVariables.debugInfo != null:
		GlobalPlayerVariables.debugInfo.blinking173 = players_blinking()
		GlobalPlayerVariables.debugInfo.looking173 = !players_looking()
		GlobalPlayerVariables.debugInfo.nearPlayer173 = nearPlayer


func process_client():
	var selfID: int = multiplayer.get_unique_id()
	var onScreen: bool = $VisibleOnScreenNotifier3D.is_on_screen()
	var blinking: bool = GlobalPlayerVariables.blinking
	
	for player in playersInRadius:
		if player.get_multiplayer_authority() == multiplayer.get_unique_id():
			send_to_server.rpc(selfID, onScreen, blinking)
			return
	
	clear_state_of_player.rpc(multiplayer.get_unique_id())


@rpc("any_peer", "call_local", "reliable")
func clear_state_of_player(playerID: int):
	playersState.erase(playerID)

@rpc("any_peer", "call_local", "reliable")
func send_to_server(selfID: int, onScreen: bool, blinking: bool):
	playersState[selfID] = {"visible": onScreen, "blinking": blinking}


func process_server():
	if !multiplayer.is_server():
		return
	
	if GlobalPlayerVariables.debugInfo != null:
		GlobalPlayerVariables.debugInfo.relocationTimer = relocateTimer.time_left
		#print("Players combination: %s" % players_combination())
		#print("Players looking: %s" % players_looking())
		#print("Players blinking: %s" % players_blinking())
	
	nearPlayer = true if playersInRadius.size() > 0 else false
	if (players_blinking() or !players_looking() or players_combination() or view_obstructed()) and nearPlayer:
		try_kill_players()
		
		agent.target_position = find_closest_player().global_position
		nextPathPos = agent.get_next_path_position() - global_position
		velocity = (nextPathPos.normalized() * speed)
		move_and_slide()
		
		self.look_at(agent.target_position)
		self.rotation.x = 0
		self.rotation.z = 0
		
		play_scraping.rpc()
		
		if nearDoor != null and !waiting:
			try_break_door()
		
		return
	
	stop_scraping.rpc()


#region // CONDITIONALS FOR THE SERVER
func players_looking() -> bool:
	for peer in return_peers_in_radius():
		if playersState.get(peer) != null:
			var playerDict: Dictionary = playersState.get(peer)
			if playerDict.get("visible") == true:
				return true
	
	return false

func players_blinking() -> bool:
	for peer in return_peers_in_radius():
		if playersState.get(peer) != null:
			var playerDict: Dictionary = playersState.get(peer)
			if playerDict.get("blinking") != true:
				return false 
	
	return true

func players_combination() -> bool:
	for peer in return_peers_in_radius():
		if playersState.get(peer) != null:
			var playerDict: Dictionary = playersState.get(peer)
			if playerDict.get("blinking") != true and playerDict.get("visible") == true:
				return false
	
	return true

func view_obstructed() -> bool:
	for peerID in return_peers_in_radius():
		var player: Player = GameManager.get_player_by_id(peerID)
		var boolArray: Array[bool] = []
		
		for marker: Marker3D in visuallyObscuredMarkers:
			var collider = ZFunc.get_ray_collider(player.camera.global_position, marker.global_position)
			boolArray.append(collider == self)
		
		if !boolArray.has(true):
			return true
	
	return false
#endregion


@rpc("authority", "call_local", "reliable")
func play_scraping():
	if !stoneScrapingPlayer.playing:
		stoneScrapingPlayer.play(randf_range(0.0, 5.0))


@rpc("authority", "call_local", "reliable")
func stop_scraping():
	stoneScrapingPlayer.stop()



@rpc("any_peer", "call_local", "reliable")
func relocate(room: Room, playAmbiance: bool = false):
	if room.spawnPosFor173 == null:
		self.global_position = room.global_position
	else:
		self.global_position = room.spawnPosFor173.global_position
	
	if playAmbiance == true:
		GlobalPlayerVariables.ambienceManager.play_ambience(ZFunc.rand_from(relocationSounds))
	
	confirm_relocate()


func confirm_relocate():
	print("close to player.")
	relocating = false
	relocateTimer.stop()



@rpc("any_peer", "call_local", "reliable")
func try_relocate(playAmbiance: bool = false):
	if !multiplayer.is_server():
		return
	
	print("trying relocate (starting timer)...")
	relocateTimer.start()
	relocating = true
	await relocateTimer.timeout
	
	if self.global_position.y < -200:
		self.global_position += Vector3(0, -100, 0)
	
	var nearbyRooms := []
	var players: Array = get_tree().get_nodes_in_group("player")
	for player: Player in players:
		nearbyRooms.append_array(player.return_nearby_rooms())
	var room: Room = ZFunc.rand_from(nearbyRooms)
	var closestPlayer: Player = find_closest_player()
	var roomPlyrDist: float = find_closest_player().global_position.distance_to(room.global_position)
	
	if !room.can173Spawn:
		try_relocate()
		return
	if roomPlyrDist > tooFarFromPlayers or roomPlyrDist < tooCloseToPlayers:
		print("too close or too far from players! dist: %s" % roomPlyrDist)
		try_relocate()
		return
	if nearbyRooms.size() <= 0:
		print("no nearby rooms!")
		try_relocate()
		return
	
	print("Found Room: %s! -- Distance: %sm" % [room.name, roomPlyrDist])
	relocate.rpc(room, playAmbiance)


func try_kill_players():
	for player in playersInKillRange:
		if player.dead == true:
			return
		
		$NeckSnap.stream = neckSnapSounds[randi_range(0, neckSnapSounds.size()-1)]
		$NeckSnap.play()
		
		player.take_damage(9999)


var waiting: bool = false
func try_break_door():
	if nearDoor.doorOpen:
		return
	
	waiting = true
	print("Trying to break through door!")
	
	await get_tree().create_timer(2).timeout
	waiting = false
	if ZFunc.randInPercent(breakDoorChance):
		if nearDoor != null:
			nearDoor.scp_173_open.rpc()
			print("Broke through door!")


func find_closest_player() -> Player:
	var closestDist: float = INF
	var closestPlayer: Player
	
	var players = get_tree().get_nodes_in_group("player")
	
	for player: Player in players:
		var dist: float = self.global_position.distance_to(player.global_position)
		
		if dist < closestDist:
			closestDist = dist
			closestPlayer = player
	
	return closestPlayer


func return_peers_in_radius() -> Array[int]:
	var peerArray: Array[int]
	for player in playersInRadius:
		peerArray.append(player.get_multiplayer_authority())
	return peerArray


@rpc("any_peer", "call_local", "reliable")
func teleport_to_player(position: Vector3):
	self.global_position = position


func _on_door_detection_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("door"):
		nearDoor = body
func _on_door_detection_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("door"):
		nearDoor = null


func _on_chase_radius_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		if body.dead == true:
			return
		
		playersInRadius.append(body)
		relocateTimer.stop()

func _on_chase_radius_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		playersInRadius.erase(body)
		
		if playersInRadius.size() <= 0:
			try_relocate(true)


func _on_neck_snap_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		playersInKillRange.append(body)
func _on_neck_snap_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		playersInKillRange.erase(body)
