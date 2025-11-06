extends Node3D
class_name Elevator

var rng: RandomNumberGenerator

var destination: Node3D
var otherElevator: Elevator

@export var id: String
@export var ownDestination: Node3D
@export var door: Door

@export var beepPlayer: AudioStreamPlayer
@export var movingPlayer: AudioStreamPlayer

var moving: bool = false
@export var atCurrentFloor := false
var playersInElevator: Array[Player]


func _ready() -> void:
	rng = GameManager.rng
	rng.seed = GameManager.rng.seed
	
	SignalBus.connect("connect_elevator", elevator_setup)
	
	await SignalBus.level_generation_finished
	SignalBus.emit_signal("connect_elevator", self)


func elevator_setup(passedElevator: Elevator):
	if id == passedElevator.id and passedElevator != self:
		otherElevator = passedElevator
		if otherElevator.ownDestination != ownDestination:
			destination = otherElevator.ownDestination
			
			if atCurrentFloor == false:
				atCurrentFloor = rng.randi_range(0, 1)
	
	#print("")
	#print("Elevator: %s" % self)
	#print("Own Destination: %s" % ownDestination)
	#print("Destination: %s" % destination)
	#print("")

@rpc("reliable", "call_local", "any_peer")
func activate():
	if moving:
		if randi_range(1, 10) == 10:
			GlobalPlayerVariables.interactionText.display("Pressing the button more wont make the elevator come any faster.")
		else:
			GlobalPlayerVariables.interactionText.display("You pressed the button, but the elevator was already moving.")
	
	if !atCurrentFloor:
		move_elevator_to_floor()
	elif atCurrentFloor and !door.doorOpen:
		door.open()
	elif atCurrentFloor and door.doorOpen:
		if id == "":
			door.close()
			await get_tree().create_timer(1.5).timeout
			movingPlayer.play()
			GameManager.game_win()
			return
		
		send_elevator()


func move_elevator_to_floor():
	GlobalPlayerVariables.interactionText.display("You called the elevator.")
	
	moving = true
	
	movingPlayer.play()
	await get_tree().create_timer(8).timeout
	beepPlayer.play()
	door.open()
	
	atCurrentFloor = true
	moving = false


func send_elevator():
	if moving:
		return
	moving = true
	
	door.close()
	otherElevator.door.close()
	await get_tree().create_timer(1).timeout
	
	movingPlayer.play()
	await get_tree().create_timer(6).timeout
	
	for player in playersInElevator:
		var fromTransform := ownDestination.global_transform
		var toTransform := destination.global_transform
		
		var playerOffset := fromTransform.affine_inverse() * player.global_transform
		player.global_transform = toTransform * playerOffset
		
		player.blinkinator.blink()
	
	await get_tree().create_timer(1).timeout
	
	beepPlayer.play()
	otherElevator.door.open()
	
	otherElevator.atCurrentFloor = true
	atCurrentFloor = false
	
	moving = false


func _on_inside_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		playersInElevator.append(body)
func _on_inside_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		playersInElevator.erase(body)
