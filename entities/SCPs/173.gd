extends CharacterBody3D

@export var disabled: bool = false

@export var speed: float
@export var agent: NavigationAgent3D

@export var tooCloseToPlayers: float 
@export var tooFarFromPlayers: float 

@export var neckSnapSounds: Array[AudioStream]
@export var relocationSounds: Array[AudioStream]

@export var playersLooking: Array[bool]
var playersInRadius: Array[Player]
var nearPlayer: bool = false
var relocating: bool = false

var playerInKillRange: Player = null
var nearDoor: Door 

func _on_visible_on_screen_notifier_3d_screen_entered() -> void:
	pass
func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
	pass


func _ready() -> void:
	if disabled == true:
		queue_free()
	
	SignalBus.connect("activate_173", relocate)
	SignalBus.connect("teleport_173_to_player", teleport_to_player)
	
	$TenTimesASecond.connect("timeout", process_one)
	$StoneScraping.connect("finished", play_scraping)

func play_scraping():
	if (players_blinking() or !players_looking()) and nearPlayer:
		$StoneScraping.play(randf_range(0.0, 5.0))

var nextPathPos := Vector3.ZERO
func process_one():
	if !multiplayer.is_server():
		return
	
	if GlobalPlayerVariables.debugInfo != null:
		GlobalPlayerVariables.debugInfo.blinking173 = players_blinking()
		GlobalPlayerVariables.debugInfo.looking173 = !players_looking()
		GlobalPlayerVariables.debugInfo.nearPlayer173 = nearPlayer
	
	nearPlayer = true if playersInRadius.size() > 0 else false
	#print("near player?: %s -- all players blinking?: %s -- all players looking away?: %s" % [nearPlayer, players_blinking(), !players_looking()])
	
	if (players_blinking() or !players_looking()) and nearPlayer:
		#try_kill_player(playerInKillRange)
		
		agent.target_position = find_closest_player().global_position
		nextPathPos = agent.get_next_path_position() - global_position
	
		velocity = (nextPathPos.normalized() * speed)
		
		move_and_slide()
		
		self.look_at(agent.target_position)
		self.rotation.x = 0
		self.rotation.z = 0
		
		if !$StoneScraping.playing:
			play_scraping()
			if nearDoor != null and !waiting:
				try_break_door()
		
		return
	
	$StoneScraping.stop()


func players_blinking() -> bool: # Returns true if ALL players are blinking
	for player: Player in playersInRadius:
		if player.blinking != true:
			return false
		else:
			return true
	
	return false

func players_looking() -> bool: # Returns false if ALL players are looking away
	playersLooking.clear()
	on_screen_check.rpc()
	if !playersLooking.has(true):
		return false
	return true

@rpc("any_peer", "call_local", "reliable")
func on_screen_check():
	playersLooking.append($VisibleOnScreenNotifier3D.is_on_screen())

var waiting: bool = false
func try_break_door():
	if nearDoor.doorOpen:
		return
	
	waiting = true
	print("Trying to break through door!")
	
	await get_tree().create_timer(2).timeout
	waiting = false
	if ZFunc.randInPercent(25):
		if nearDoor != null:
			nearDoor.one_seven_three_open.rpc()
			print("Broke through door!")


func relocate(playAmbiance: bool = false):
	var rooms = GlobalPlayerVariables.facilityManager.playerNearbyRooms
	if rooms.size() <= 0:
		print("no nearby rooms")
		try_relocate()
		return
	
	print("relocating!")
	relocating = true
	
	var room: Room = rooms[randi_range(0, rooms.size()-1)]
	
	if room != null and !room.position.distance_to(GlobalPlayerVariables.playerPosition) < 17:
		if !room.can173Spawn:
			try_relocate()
		
		if room.spawnPosFor173 == null:
			self.global_position = room.global_position + Vector3(0, 0.25, 0)
		else:
			self.global_position = room.spawnPosFor173.global_position + Vector3(0, 0.25, 0)
	
	if playAmbiance == true:
		GlobalPlayerVariables.ambienceManager.play_ambience(relocationSounds[randi_range(0, 1)])
	
	if self.position.distance_to(GlobalPlayerVariables.playerPosition) < 40:
		print("close to player")
		relocating = false
		$"RelocateTimer".stop()
		return
	
	try_relocate()


func try_relocate():
	await $"RelocateTimer".timeout
	if $"RelocateTimer".is_stopped():
		$"RelocateTimer".start()
	relocate()


func try_kill_player(player: Player):
	if playerInKillRange == null:
		return
	
	$NeckSnap.stream = neckSnapSounds[randi_range(0, neckSnapSounds.size()-1)]
	$NeckSnap.play()
	
	player.take_damage(9999)
	playerInKillRange = null


func find_closest_player() -> Player:
	var closestDist: float = INF
	var closestPlayer: Player
	
	for player: Player in playersInRadius:
		var dist: float = self.global_position.distance_to(player.global_position)
		
		if dist < closestDist:
			dist = closestDist
			closestPlayer = player
	
	return closestPlayer


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
		playersInRadius.append(body)
		
		$"RelocateTimer".stop()

func _on_chase_radius_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		playersInRadius.erase(body)
		
		$"RelocateTimer".start()
		await $"RelocateTimer".timeout
		relocate(true)


func _on_neck_snap_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		playerInKillRange = body
func _on_neck_snap_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		playerInKillRange = null
