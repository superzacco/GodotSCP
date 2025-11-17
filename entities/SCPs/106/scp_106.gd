extends CharacterBody3D

@export var speed: float
var chasing: bool = false

@export var minSpawnTime: int 
@export var maxSpawnTime: int 

@export var agent: NavigationAgent3D
@export var animationPlayer: AnimationPlayer
@export var corrosiveDecal: PackedScene

@export var ermergeSounds: Array[AudioStream]
@export var chaseAmbiance: AudioStream
@export var sendtoPDSound: AudioStream
@export var PDAmbiance: AudioStream

var audioPlaybackGlobal: AudioStreamPlaybackPolyphonic
var ambiance: AmbienceManager


func _ready() -> void:
	SignalBus.connect("activate_106", on_106_activated)
	
	$CollisionShape3D.position += Vector3(0, -15, 0)
	
	ambiance = GlobalPlayerVariables.ambienceManager
	
	await SignalBus.level_generation_finished
	
	$SummonTimer.connect("timeout", on_106_activated)
	$SummonTimer.start(randi_range(minSpawnTime,maxSpawnTime))


func _physics_process(delta: float) -> void:
	if GlobalPlayerVariables.debugInfo != null:
		GlobalPlayerVariables.debugInfo.summonTimer = $SummonTimer.time_left
	
	if chasing == true:
		var nextPathPos := Vector3.ZERO
		
		agent.target_position = GlobalPlayerVariables.playerPosition
		nextPathPos = agent.get_next_path_position() - position
		velocity = (nextPathPos.normalized() * speed)
		
		if self.get_real_velocity().length() < 0.001:
			self.global_position += velocity * 0.01
		
		move_and_slide()
		
		self.look_at(agent.target_position)
		self.rotation.x = 0
		self.rotation.z = 0

func on_106_activated():
	rise.rpc(GlobalPlayerVariables.playerPosition)

@rpc("any_peer", "call_local", "reliable")
func rise(position: Vector3):
	$SummonTimer.stop()
	
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
	spawn_repeating_decal()


func end_chase():
	if chasing == false:
		return
	
	ZFunc.fade_out($Chase, 5.0)
	$Breathing.stop()
	
	chasing = false
	$CollisionShape3D.position += Vector3(0, -15, 0)
	
	$"Decal Timer".stop()
	spawn_first_decal()
	
	animationPlayer.stop()
	animationPlayer.play_backwards("rise")
	
	$SummonTimer.start(randi_range(minSpawnTime,maxSpawnTime))


func on_send_player_to_pd(player: Player):
	player.take_damage(25.0, "106")
	$SendToPD.play()


func spawn_first_decal():
	var corrode: CorrosiveDecal = corrosiveDecal.instantiate()
	get_tree().root.add_child(corrode)
	
	corrode.global_position = self.global_position
	corrode.finalSize = 3.5


func spawn_repeating_decal():
	if !chasing:
		return
	
	$"Decal Timer".start(0.65)
	await $"Decal Timer".timeout
	
	var randomSize = randf_range(1.0, 1.5)
	var corrode: CorrosiveDecal = corrosiveDecal.instantiate()
	
	get_tree().root.add_child(corrode)
	corrode.global_position = self.global_position
	
	corrode.speed = 2.0
	corrode.finalSize = randomSize
	
	spawn_repeating_decal()


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


func _on_chase_radius_area_exited(area: Area3D) -> void:
	if area.is_in_group("noclip_safe_player_area"):
		end_chase()


func _on_teleportzone_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and chasing == true:
		var player: Player = body
		on_send_player_to_pd(player)
