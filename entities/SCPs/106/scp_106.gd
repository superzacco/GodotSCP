extends CharacterBody3D

@export var speed: float
var chasing: bool = false

@export var agent: NavigationAgent3D
@export var animationPlayer: AnimationPlayer
@export var corrosiveDecal: PackedScene

@export var stepSounds: Array[AudioStream]
@export var chaseAmbiance: AudioStream
var audioStreamPlaybackPolyphonic: AudioStreamPlaybackPolyphonic


func _ready() -> void:
	SignalBus.connect("activate_106", on_106_activated)
	
	$StepSounds.play()
	audioStreamPlaybackPolyphonic = $StepSounds.get_stream_playback()

func on_106_activated():
	rise.rpc(GlobalPlayerVariables.playerPosition)


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


@rpc("any_peer", "call_local", "reliable")
func rise(position: Vector3):
	self.global_position = GlobalPlayerVariables.playerPosition
	
	animationPlayer.stop()
	animationPlayer.play("rise")
	spawn_first_decal()
	
	await animationPlayer.animation_finished
	
	begin_chase()



@rpc("any_peer", "call_local", "reliable")
func begin_chase():
	chasing = true
	$CollisionShape3D.disabled = false
	animationPlayer.play("walk")
	
	#step()
	spawn_repeating_decal()


func end_chase():
	if !chasing == true:
		return
	
	chasing = false
	$CollisionShape3D.disabled = true
	$"Decal Timer".stop()
	
	animationPlayer.stop()
	animationPlayer.play_backwards("rise")
	spawn_first_decal()


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
