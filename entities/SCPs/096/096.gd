extends Monster

@export var body: PackedScene
@export var screamPlayer: AudioStreamPlayer3D

@export var wanderSpeed: float = 20

var first := true
var state: States = States.WANDER
enum States {
	WANDER,
	CHASE
}

var facilityManager: FacilityManager = null
func _ready() -> void:
	super()
	SignalBus.teleport_096_to_player.connect(teleport_to)
	facilityManager = GlobalPlayerVariables.facilityManager


func process_one() -> void:
	process_client()
	if !should_process() or !multiplayer.is_server(): return
	process_server()


func process_server():
	if playersInAttackArea.size() > 0:
		attack.rpc()
	
	var distToTarget := agent.target_position.distance_to(global_position)
	if distToTarget < 1 and state == States.CHASE:
		stop_chase.rpc()
		kill_npc.rpc()
	
	nextPathPos = agent.get_next_path_position() - global_position
	var currSpeed = speed if state == States.CHASE else wanderSpeed
	
	velocity = (nextPathPos.normalized() * (currSpeed * 0.1))

func process_client():
	canAttack = true if state == States.CHASE else false
	match state:
		States.WANDER:
			modelAnimations.play("walk")
		States.CHASE:
			modelAnimations.play("run")


func _process(delta: float) -> void:
	if !should_process(): return
	
	look_at_pos(global_position + velocity)
	move_and_slide()



func teleport_to(pos: Vector3):
	self.global_position = pos



func _on_run_timer_timeout() -> void:
	go_kill_random_npc()

func go_kill_random_npc():
	if !should_process(): return
	
	var randomRooms: Array[Room] = []
	
	for i in 2: 
		randomRooms.append(ZFunc.rand_from(facilityManager.rooms))
	
	var startPos: Vector3
	var targetPos: Vector3 = randomRooms[1].return_173_spawn_point()
	
	if first:
		startPos = facilityManager.chamber096.return_173_spawn_point()
	else:
		startPos = self.global_position
	
	first = false
	setup_npc.rpc(targetPos)
	send_096.rpc(startPos, targetPos)


@rpc("authority", "call_local", "reliable")
func stop_chase():
	$RunTimer.start(30)
	agent.target_position = ZFunc.rand_from(facilityManager.rooms).global_position
	state = States.WANDER
	screamPlayer.stop()

@rpc("authority", "call_local", "reliable")
func send_096(startPos: Vector3, targetPos: Vector3):
	state = States.CHASE
	
	if !screamPlayer.playing:
		screamPlayer.play()
	global_position = startPos
	agent.target_position = targetPos

var targetNPC: Body
@rpc("authority", "call_local", "reliable")
func kill_npc():
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
