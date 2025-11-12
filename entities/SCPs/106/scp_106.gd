extends CharacterBody3D

@export var speed: float

@export var agent: NavigationAgent3D
@export var animationPlayer: AnimationPlayer
@export var corrosiveDecal: PackedScene


func _ready() -> void:
	SignalBus.connect("activate_106", on_106_activated)

func on_106_activated():
	rise.rpc(GlobalPlayerVariables.playerPosition)


func _physics_process(delta: float) -> void:
	if animationPlayer.current_animation == "walk":
		var nextPathPos := Vector3.ZERO
		
		agent.target_position = GlobalPlayerVariables.playerPosition
		nextPathPos = agent.get_next_path_position() - position
		velocity = (nextPathPos.normalized() * speed)
		
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
	animationPlayer.play("walk")
	
	spawn_repeating_decal()


func spawn_first_decal():
	var corrode: CorrosiveDecal = corrosiveDecal.instantiate()
	get_tree().root.add_child(corrode)
	
	corrode.global_position = self.global_position
	corrode.finalSize = 3.5


func spawn_repeating_decal():
	$"Decal Timer".start(0.75)
	await $"Decal Timer".timeout
	
	var randomSize = randf_range(1.25, 1.75)
	
	var corrode: CorrosiveDecal = corrosiveDecal.instantiate()
	get_tree().root.add_child(corrode)
	corrode.global_position = self.global_position
	
	corrode.speed = 2.0
	corrode.finalSize = randomSize
	
	spawn_repeating_decal()
