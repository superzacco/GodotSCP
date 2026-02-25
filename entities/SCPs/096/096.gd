extends Monster


func _ready() -> void:
	super()
	canAttack = false
	SignalBus.teleport_096_to_player.connect(teleport_to)
	
	await SignalBus.level_generation_finished
	go_kill_random_npc()


func process_one() -> void:
	if !should_process(): return
	
	modelAnimations.play("run")
	
	if playersInAttackArea.size() > 0:
		attack()
	
	nextPathPos = agent.get_next_path_position() - global_position
	velocity = (nextPathPos.normalized() * (speed * 0.1))


func _process(delta: float) -> void:
	if !should_process(): return
	
	look_at_pos(global_position + velocity)
	if agent.target_position.distance_to(global_position) < 1:
		print("reached!")
		go_kill_random_npc()
	
	move_and_slide()


func teleport_to(pos: Vector3):
	self.global_position = pos


func _on_run_timer_timeout() -> void:
	go_kill_random_npc()


func go_kill_random_npc():
	if !multiplayer.is_server():
		return
	
	var facilityManager = GlobalPlayerVariables.facilityManager
	var finishedRooms = facilityManager.rooms
	var randomRooms: Array[Room] = []
	
	for i in 2: 
		randomRooms.append(ZFunc.rand_from(finishedRooms))
	
	var startPos: Vector3 = randomRooms[0].return_173_spawn_point()
	var targetPos: Vector3 = randomRooms[1].return_173_spawn_point()
	
	send_096.rpc(startPos, targetPos)


@rpc("authority", "call_local", "reliable")
func send_096(startPos: Vector3, targetPos: Vector3):
	global_position = startPos
	agent.target_position = targetPos



func should_process() -> bool:
	if !enabled:
		return false
	
	return true


func _on_door_break_radius_body_entered(body: Node3D) -> void:
	if body.is_in_group("door"):
		body.open()
