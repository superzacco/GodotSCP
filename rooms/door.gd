extends StaticBody3D
class_name Door

@export var doorPanel:PackedScene
@export var animationPlayer: AnimationPlayer

@export var openSounds: Array[AudioStream]
@export var closeSounds: Array[AudioStream]

@export var openOnSpawn: bool = false

@export var closableBy079: bool = false
@export var openableBy173: bool = false
var generatedDoor: bool = false

var broken: bool = false
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
	if doorOpen or broken:
		return
	
	if openSounds.size() > 0:
		$Open.stream = openSounds[randi_range(0, openSounds.size()-1)]
		$Open.play()
	animationPlayer.play("open")
	doorOpen = true


@rpc("reliable", "call_local", "any_peer")
func close():
	if !doorOpen or broken:
		return
	
	if openSounds.size() > 0:
		$Close.stream = closeSounds[randi_range(0, closeSounds.size()-1)]
		$Close.play()
	animationPlayer.play("close")
	doorOpen = false




@rpc("reliable", "call_local", "any_peer")
func one_seven_three_open():
	if !openableBy173 or broken:
		return
	
	$"173 Open".play()
	animationPlayer.play("open")
	doorOpen = true


@rpc("reliable", "call_local", "any_peer")
func scp_079_close():
	if !closableBy079 == true or broken:
		return
	
	animationPlayer.speed_scale = 1.5
	animationPlayer.play("close")
	doorOpen = false
	$"079Close".play()
	await animationPlayer.animation_finished
	animationPlayer.speed_scale = 1


@export_group("Door Parts")
@export var doorCols: Array[CollisionShape3D]
@export var doorMeshes: Array[MeshInstance3D]
@rpc("reliable", "call_local", "any_peer")
func scp_096_break(pos: Vector3):
	if broken or doorOpen:
		return
	
	broken = true
	
	$"096Break".play()
	await get_tree().create_timer(0.15).timeout
	
	for i in range(2):
		if doorMeshes[i] != null:
			doorMeshes[i].queue_free()
		if doorCols[i] != null:
			doorCols[i].queue_free()
		
		var dirToDoors = pos.direction_to(self.global_position)
		var panel: RigidBody3D = doorPanel.instantiate()
		
		self.add_child(panel)
		panel.global_position = self.global_position
		panel.apply_impulse(dirToDoors * 10)
		
		if i == 2:
			panel.rotation_degrees.y += 180
