extends Monster

var chasing: bool = false

@export var minSpawnTime: int 
@export var maxSpawnTime: int 

var playersInRadius: Array[Player]
@export var animationPlayer: AnimationPlayer
@export var corrosiveDecal: PackedScene

@export var summonTimer: Timer
@export var corrosiveDecalTimer: Timer 

@export var ermergeSounds: Array[AudioStream]
@export var chaseAmbiance: AudioStream
@export var sendtoPDSound: AudioStream
@export var PDAmbiance: AudioStream

var audioPlaybackGlobal: AudioStreamPlaybackPolyphonic


func _ready() -> void:
	SignalBus.connect("activate_106", on_106_activated)
	$CollisionShape3D.position += Vector3(0, -15, 0)
	
	await SignalBus.level_generation_finished
	
	corrosiveDecalTimer.timeout.connect(spawn_repeating_decal)
	summonTimer.timeout.connect(on_106_activated)
	summonTimer.start(randi_range(minSpawnTime,maxSpawnTime))


func _physics_process(delta: float) -> void:
	if !should_process():
		return
	
	if GlobalPlayerVariables.debugInfo != null:
		GlobalPlayerVariables.debugInfo.summonTimer = summonTimer.time_left
	
	process_client()
	process_server()


func process_client():
	pass


func process_server():
	if !multiplayer.is_server():
		return
	
	if chasing == true:
		var nextPathPos := Vector3.ZERO
		
		agent.target_position = find_closest_player().global_position
		nextPathPos = agent.get_next_path_position() - global_position
		velocity = (nextPathPos.normalized() * speed)
		
		self.global_position += velocity * 0.01
		
		look_at_pos(global_position + velocity)
		move_and_slide()


func on_106_activated():
	rise.rpc(GlobalPlayerVariables.playerPosition)

@rpc("any_peer", "call_local", "reliable")
func rise(position: Vector3):
	summonTimer.stop()
	
	$Decay.stream = ZFunc.rand_from(ermergeSounds)
	$Decay.play()
	
	$Breathing.play()
	ZFunc.fade_in($Breathing, 4.0)
	
	$Rising.play()
	ZFunc.fade_in($Rising, 1.0)
	
	self.global_position = GlobalPlayerVariables.playerPosition
	
	animationPlayer.stop()
	animationPlayer.play("rise")
	spawn_first_decal()
	
	await animationPlayer.animation_finished
	
	begin_chase()


@rpc("any_peer", "call_local", "reliable")
func begin_chase():
	$Chase.play()
	
	chasing = true
	$CollisionShape3D.position += Vector3(0, 15, 0)
	animationPlayer.play("walk")
	
	#step()
	corrosiveDecalTimer.start()


func end_chase():
	ZFunc.fade_out($Chase, 5.0)
	$Breathing.stop()
	
	chasing = false
	$CollisionShape3D.position += Vector3(0, -15, 0)
	
	corrosiveDecalTimer.stop()
	spawn_first_decal()
	
	animationPlayer.stop()
	animationPlayer.play_backwards("rise")
	
	summonTimer.start(randi_range(minSpawnTime,maxSpawnTime))


func on_send_player_to_pd(player: Player):
	player.take_damage(25.0, Damage.Types.TYPE_106)
	$SendToPD.play()


func spawn_first_decal():
	var corrode: CorrosiveDecal = corrosiveDecal.instantiate()
	get_tree().root.add_child(corrode)
	
	corrode.global_position = self.global_position
	corrode.finalSize = 3.5


func spawn_repeating_decal():
	if !chasing:
		corrosiveDecalTimer.stop()
		return
	
	var randomSize = randf_range(1.25, 1.75)
	var corrode: CorrosiveDecal = corrosiveDecal.instantiate()
	
	get_tree().root.add_child(corrode)
	corrode.global_position = self.global_position
	
	corrode.speed = 2.0
	corrode.finalSize = randomSize


#func step():
	#if !chasing == true:
		#return
	#
	#if !audioPlaybackGlobal == null:
		#audioPlaybackGlobal.play_stream(ZFunc.rand_from(stepSounds))
	#
	#$StepSounds/Timer.start(0.74)
	#await $StepSounds/Timer.timeout
	#step()


func stop_pd_ambiance():
	ZFunc.fade_out($PDAmbiance, 5.0)


func _on_chase_radius_area_entered(area: Area3D) -> void:
	if area.is_in_group("noclip_player_area"):
		playersInRadius.append(area.get_parent())

func _on_chase_radius_area_exited(area: Area3D) -> void:
	if area.is_in_group("noclip_player_area"):
		playersInRadius.erase(area.get_parent())
		
		if playersInRadius.size() <= 0:
			end_chase()


func _on_teleportzone_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and chasing == true:
		var player: Player = body
		on_send_player_to_pd(player)
