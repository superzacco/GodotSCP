extends CharacterBody3D

@export var disabled: bool = false

@export var speed: float
@export var agent: NavigationAgent3D

@export var tooCloseToPlayers: float 
@export var tooFarFromPlayers: float 
@export var breakDoorChance: float

@export var relocateTimer: Timer
@export var stoneScrapingPlayer: AudioStreamPlayer3D
@export var neckSnapSounds: Array[AudioStream]
@export var relocationSounds: Array[AudioStream]

var playersState := {}
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
	if disabled == true:
		queue_free()
		return
	
	SignalBus.connect("activate_173", relocate)
	SignalBus.connect("teleport_173_to_player", teleport_to_player)
	SignalBus.connect("relocate_173", relocate)
	
	$TenTimesASecond.connect("timeout", process_one)
	stoneScrapingPlayer.connect("finished", play_scraping)


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
		GlobalPlayerVariables.debugInfo.relocationTimer = $RelocateTimer.time_left
		#print("Players combination: %s" % players_combination())
		#print("Players looking: %s" % players_looking())
		#print("Players blinking: %s" % players_blinking())
	
	nearPlayer = true if playersInRadius.size() > 0 else false
	if (players_blinking() or !players_looking() or players_combination()) and nearPlayer:
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


#region // CONDITIONALS
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
#endregion


@rpc("authority", "call_local", "reliable")
func play_scraping():
	if !stoneScrapingPlayer.playing:
		stoneScrapingPlayer.play(randf_range(0.0, 5.0))

@rpc("authority", "call_local", "reliable")
func stop_scraping():
	stoneScrapingPlayer.stop()


func relocate(playAmbiance: bool = false):
	var roomsNearbyPlayers = []
	
	for player: Player in get_tree().get_nodes_in_group("player"):
		roomsNearbyPlayers.append_array(player.return_nearby_rooms())
	
	if roomsNearbyPlayers.size() <= 0:
		print("no nearby room!")
		try_relocate()
		return
	
	print("Relocating! -- Neary Rooms [ %s ]" % roomsNearbyPlayers.size())
	relocating = true
	
	var room: Room = ZFunc.rand_from(roomsNearbyPlayers)
	
	if !room.can173Spawn:
		try_relocate()
		return
	
	if room.spawnPosFor173 == null:
		self.global_position = room.global_position
	else:
		self.global_position = room.spawnPosFor173.global_position
	
	if distance_to_closest_player() > tooFarFromPlayers or distance_to_closest_player() < tooCloseToPlayers:
		try_relocate()
		return
	
	if playAmbiance == true:
		GlobalPlayerVariables.ambienceManager.play_ambience(ZFunc.rand_from(relocationSounds))
	
	print("Found Room: %s! -- Distance: %sm" % [room.name, distance_to_closest_player()])
	confirm_relocate()


func confirm_relocate():
	print("close to player")
	relocating = false
	relocateTimer.stop()


func try_relocate():
	if self.global_position.y < -200:
		self.global_position += Vector3(0, -100, 0)
	
	if relocateTimer.is_stopped():
		relocateTimer.start()
	
	await relocateTimer.timeout
	relocate()


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
			nearDoor.one_seven_three_open.rpc()
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

func distance_to_closest_player() -> float:
	return self.global_position.distance_to(find_closest_player().global_position)


func return_peers_in_radius() -> Array[int]:
	var peerArray: Array[int]
	for player in playersInRadius:
		peerArray.append(player.get_multiplayer_authority())
	return peerArray


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
			relocateTimer.start()
			await relocateTimer.timeout
			relocate(true)


func _on_neck_snap_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		playersInKillRange.append(body)
func _on_neck_snap_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		playersInKillRange.erase(body)
