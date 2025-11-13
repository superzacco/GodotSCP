extends StaticBody3D
class_name Door

@export var animationPlayer: AnimationPlayer

@export var openSounds: Array[AudioStream]
@export var closeSounds: Array[AudioStream]

@export var ignore079: bool = false

var doorOpen: bool = false
var opening: bool = false

func _ready() -> void:
	# // TO-DO -- FIX THIS SHIT
	self.global_position += Vector3(0, 3, 0)
	await SignalBus.level_generation_finished
	self.global_position -= Vector3(0, 3, 0)

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
	$"173 Open".play()
	animationPlayer.play("open")
	doorOpen = true
	


@rpc("reliable", "call_local", "any_peer")
func scp_079_close():
	if ignore079 == true:
		return
	
	animationPlayer.speed_scale = 1.5
	animationPlayer.play("close")
	doorOpen = false
	$"079Close".play()
	await animationPlayer.animation_finished
	animationPlayer.speed_scale = 1
	
