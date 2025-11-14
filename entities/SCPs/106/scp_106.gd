extends CharacterBody3D

@export var speed: float
var chasing: bool = false

@export var minSpawnTime: int 
@export var maxSpawnTime: int 

@export var agent: NavigationAgent3D
@export var animationPlayer: AnimationPlayer
@export var corrosiveDecal: PackedScene

@export var stepSounds: Array[AudioStream]
@export var chaseAmbiance: AudioStream
@export var sendtoPDSound: AudioStream
@export var laugh: AudioStream
@export var breathing: AudioStream
@export var PDAmbiance: AudioStream

var audioStreamPlaybackPolyphonic: AudioStreamPlaybackPolyphonic
var ambiance: AmbienceManager


func _ready() -> void:
	SignalBus.connect("activate_106", on_106_activated)
	
	$CollisionShape3D.position += Vector3(0, -15, 0)
	
	audioStreamPlaybackPolyphonic = $GlobalAudio.get_stream_playback()
	ambiance = GlobalPlayerVariables.ambienceManager
	
	await SignalBus.level_generation_finished
	
	$SummonTimer.connect("timeout", on_106_activated)
	$SummonTimer.start(randi_range(minSpawnTime,maxSpawnTime))


func _physics_process(delta: float) -> void:
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
	
	$Breathing.stream = breathing
	$Breathing.play()
	ZFunc.fade_in($Breathing, 7.0)
	
	$Rising.stream = sendtoPDSound
	$Rising.play()
	ZFunc.fade_in($Rising, 5.0)
	
	self.global_position = GlobalPlayerVariables.playerPosition
	
	animationPlayer.stop()
	animationPlayer.play("rise")
	spawn_first_decal()
	
	await animationPlayer.animation_finished
	
	begin_chase()


@rpc("any_peer", "call_local", "reliable")
func begin_chase():
	ambiance.play_music(chaseAmbiance)
	
	chasing = true
	$CollisionShape3D.position += Vector3(0, 15, 0)
	animationPlayer.play("walk")
	
	#step()
	spawn_repeating_decal()


func end_chase():
	if !chasing == true:
		return
	
	$Breathing.stop()
	
	chasing = false
	$CollisionShape3D.position += Vector3(0, -15, 0)
	$"Decal Timer".stop()
	
	animationPlayer.stop()
	animationPlayer.play_backwards("rise")
	spawn_first_decal()
	
	$SummonTimer.start(randi_range(minSpawnTime,maxSpawnTime))


func on_send_player_to_pd():
	audioStreamPlaybackPolyphonic.play_stream(sendtoPDSound)
	await get_tree().create_timer(0.5).timeout
	audioStreamPlaybackPolyphonic.play_stream(laugh)
	
	await get_tree().create_timer(0.5).timeout
	ambiance.play_music(PDAmbiance)


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
	
	var randomSize = randf_range(1.25, 1.75)
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
	#if !audioStreamPlaybackPolyphonic == null:
		#audioStreamPlaybackPolyphonic.play_stream(ZFunc.rand_from(stepSounds))
	#
	#$StepSounds/Timer.start(0.74)
	#await $StepSounds/Timer.timeout
	#step()


func _on_chase_radius_area_exited(area: Area3D) -> void:
	if area.is_in_group("noclip_safe_player_area"):
		end_chase()


func _on_teleportzone_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and chasing == true:
		var player: Player = body
		player.take_damage(25.0, true)
		on_send_player_to_pd()
