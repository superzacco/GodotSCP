extends StaticBody3D
class_name Door

@export var animationPlayer: AnimationPlayer

@export var openSounds: Array[AudioStream]
@export var closeSounds: Array[AudioStream]

@export var openOnSpawn: bool = false

@export var closableBy079: bool = false
@export var openableBy173: bool = false
var generatedDoor: bool = false

var doorOpen: bool = false
var opening: bool = false

func _ready() -> void:
	await SignalBus.level_generation_finished
	
	if multiplayer.is_server():
		if ZFunc.randInPercent(2) and closableBy079 == true:
			open.rpc()
	
	if openOnSpawn:
		open()

@rpc("reliable", "call_local", "any_peer")
func toggle_door():
	if !animationPlayer.is_playing():
		if doorOpen:
			close.rpc()
		else: 
			open.rpc()


@rpc("reliable", "call_local", "any_peer")
func open():
	if doorOpen:
		return
	
	if openSounds.size() > 0:
		$Open.stream = openSounds[randi_range(0, openSounds.size()-1)]
		$Open.play()
	animationPlayer.play("open")
	doorOpen = true


@rpc("reliable", "call_local", "any_peer")
func close():
	if !doorOpen:
		return
	
	if openSounds.size() > 0:
		$Close.stream = closeSounds[randi_range(0, closeSounds.size()-1)]
		$Close.play()
	animationPlayer.play("close")
	doorOpen = false


@rpc("reliable", "call_local", "any_peer")
func one_seven_three_open():
	if !openableBy173:
		return
	
	$"173 Open".play()
	animationPlayer.play("open")
	doorOpen = true


@rpc("reliable", "call_local", "any_peer")
func scp_079_close():
	if !closableBy079 == true:
		return
	
	animationPlayer.speed_scale = 1.5
	animationPlayer.play("close")
	doorOpen = false
	$"079Close".play()
	await animationPlayer.animation_finished
	animationPlayer.speed_scale = 1


@export_group("Door Parts")
@export var doorCol1: CollisionShape3D
@export var doorCol2: CollisionShape3D
@export var doorMesh1: MeshInstance3D
@export var doorMesh2: MeshInstance3D
@rpc("reliable", "call_local", "any_peer")
func scp_096_break(pos: Vector3):
	var rigidBody1 := RigidBody3D.new()
	var rigidBody2 := RigidBody3D.new()
	self.add_child(rigidBody1)
	self.add_child(rigidBody2)
	
	doorMesh1.reparent(rigidBody1)
	doorCol1.reparent(rigidBody1)
	doorMesh2.reparent(rigidBody2)
	doorCol2.reparent(rigidBody2)
	
	rigidBody1.center_of_mass_mode = RigidBody3D.CENTER_OF_MASS_MODE_CUSTOM
	rigidBody2.center_of_mass_mode = RigidBody3D.CENTER_OF_MASS_MODE_CUSTOM
	rigidBody1.global_position = doorCol1.global_position 
	rigidBody2.global_position = doorCol2.global_position
	
	var dirTowardDoors := pos.direction_to(self.global_position)
	rigidBody1.apply_impulse(dirTowardDoors * 5) 
	rigidBody1.apply_torque(Vector3(randf_range(-0.5, 0.5), randf_range(-0.5, 0.5), randf_range(-0.5, 0.5)))
	rigidBody2.apply_torque(Vector3(randf_range(-0.5, 0.5), randf_range(-0.5, 0.5), randf_range(-0.5, 0.5)))
	rigidBody2.apply_impulse(dirTowardDoors * 5) 
