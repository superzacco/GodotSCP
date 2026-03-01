extends Monster

@export var body: PackedScene
@export var chasePlayer: AudioStreamPlayer
@export var screamPlayer: AudioStreamPlayer3D
@export var idlePlayer: AudioStreamPlayer3D
@export var angerPlayer: AudioStreamPlayer3D
@export var faceVisibleNotifier: VisibleOnScreenNotifier3D

@export var wanderSpeed: float = 20

var firstNPCKill := true
var state: States = States.WANDER
enum States {
	WANDER,
	ANGER,
	CHASE
}

var targetedPlayer: Player = null

var facilityManager: FacilityManager = null
var localPlayer: Player = null
var playerCamera: Camera3D = null
func _ready() -> void:
	super()
	SignalBus.teleport_096_to_player.connect(teleport_to)
	
	await get_tree().create_timer(0.1).timeout
	localPlayer = GlobalPlayerVariables.player
	playerCamera = localPlayer.camera
	facilityManager = GlobalPlayerVariables.facilityManager


func process_one() -> void:
	process_client()
	if !should_process(): return
	process_server()


func process_server():
	if playersInAttackArea.size() > 0 and state == States.CHASE:
		attack.rpc()
	
	if targetNPC != null:
		var distToTargetNPC := targetNPC.global_position.distance_to(global_position)
		if distToTargetNPC < 0.25 and state == States.CHASE:
			stop_chase.rpc()
			kill_npc.rpc()
	
	if state != States.ANGER:
		nextPathPos = agent.get_next_path_position() - global_position
	
	var currSpeed = speed if state == States.CHASE else wanderSpeed
	print(currSpeed)
	
	velocity = (nextPathPos.normalized() * (currSpeed * 0.1))


var faceJuice: int = 0
func process_client():
	if face_visible_to_camera():
		faceJuice += 34
		if faceJuice > 100:
			if state == States.WANDER:
				get_angry.rpc(multiplayer.get_unique_id())
	else:
		faceJuice = 0
	
	canAttack = true if state == States.CHASE else false
	match state:
		States.WANDER:
			modelAnimations.play("walk")
		States.CHASE:
			modelAnimations.play("run")
		States.ANGER:
			modelAnimations.play("idle")


func _process(delta: float) -> void:
	if !should_process(): return
	
	look_at_pos(global_position + velocity)
	move_and_slide()


@rpc("any_peer", "call_local", "reliable")
func set_state(states: States):
	state = states


func face_visible_to_camera() -> bool:
	if playerCamera == null:
		return false
	
	var camPos: Vector3 = playerCamera.global_position
	var facePos: Vector3 = faceVisibleNotifier.global_position
	
	if ZFunc.get_ray_collider(camPos, facePos) == null: 
		if faceVisibleNotifier.is_on_screen():
			if !GlobalPlayerVariables.blinking:
				return true
	
	return false


@rpc("any_peer", "call_local", "reliable")
func get_angry(targetID: int):
	print("096 is angry at player: %s" % targetID)
	set_state.rpc(States.ANGER)
	angerPlayer.play()
	
	await get_tree().create_timer(30).timeout
	
	var targetPlayer: Player = GameManager.get_player_by_id(targetID)
	send_096.rpc(targetPlayer)
	print("scp 096 on %s chasing player: %s" % [multiplayer.get_unique_id(), targetID])


func teleport_to(pos: Vector3):
	self.global_position = pos



func _on_run_timer_timeout() -> void:
	go_kill_random_npc()

func go_kill_random_npc():
	if !should_process(): return
	
	var randomRooms: Array[Room] = []
	
	for i in 2: 
		randomRooms.append(ZFunc.rand_from(facilityManager.rooms))
	
	var startPos: Vector3 = self.global_position
	var targetPosMarker: Node3D = randomRooms[1].return_173_spawn_point()
	
	if firstNPCKill:
		firstNPCKill = false
		startPos = facilityManager.chamber096.return_173_spawn_point_position()
	
	setup_npc.rpc(targetPosMarker.global_position)
	send_096.rpc(targetPosMarker, startPos)


@rpc("authority", "call_local", "reliable")
func stop_chase():
	agent.target_position = ZFunc.rand_from(facilityManager.rooms).global_position
	set_state.rpc(States.WANDER)
	targetedPlayer = null
	idlePlayer.play()
	screamPlayer.stop()

@rpc("authority", "call_local", "reliable")
func send_096(target: Node3D, startPos: Vector3 = self.global_position):
	var targetPos: Vector3 = target.global_position
	set_state.rpc(States.CHASE)
	
	if target.is_in_group("player"):
		var player: Player = target
		var ID := player.get_multiplayer_authority()
		if ID == multiplayer.get_remote_sender_id():
			chasePlayer.play()
		
		targetedPlayer = player
	
	if !screamPlayer.playing:
		screamPlayer.play()
	global_position = startPos
	agent.target_position = targetPos

var targetNPC: Body
@rpc("authority", "call_local", "reliable")
func kill_npc():
	if targetNPC != null:
		targetNPC.play_dead()
		targetNPC = null

@rpc("authority", "call_local", "reliable")
func setup_npc(targetPos: Vector3):
	targetNPC = body.instantiate()
	get_tree().root.add_child(targetNPC)
	targetNPC.global_position = targetPos-Vector3(0,1,0)



func should_process() -> bool:
	if !enabled or !multiplayer.is_server():
		return false
	
	return true


func _on_door_break_radius_body_entered(body: Node3D) -> void:
	if body.is_in_group("door"):
		if state != States.CHASE:
			return
		
		var door: Door = body
		door.scp_096_break.rpc(self.global_position)
