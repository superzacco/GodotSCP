extends StaticBody3D
class_name Lever

signal lever_activated
signal lever_deactivated

@export var handle: MeshInstance3D
@export var leverFlipPlayer: AudioStreamPlayer3D

@export var lockAfterActivating: bool = false
var interacting: bool = false

var leverActivated: bool = false

func _input(event: InputEvent) -> void:
	if event.is_action_released("interact"):
		interacting = false
	
	if event is InputEventMouseMotion:
		if can_move():
			handle.rotation.x += (-event.relative.y * 0.01)


func _physics_process(delta: float) -> void:
	if can_move():
		update_handle_pos.rpc(clamp(handle.rotation_degrees.x, 2.0, 178.0))
	
	if handle.rotation_degrees.x > 160.0 and !leverActivated:
		lock_handle_up.rpc()
	if handle.rotation_degrees.x < 20.0 and leverActivated:
		lock_handle_down.rpc()
	
	if !interacting:
		if leverActivated:
			handle.rotation_degrees.x = lerp(handle.rotation_degrees.x, 175.0, .1)
		else:
			handle.rotation_degrees.x = lerp(handle.rotation_degrees.x, 5.0, .1)
		
		return


func interact():
	interacting = true


@rpc("any_peer", "call_local", "unreliable")
func update_handle_pos(angle: float):
	handle.rotation_degrees.x = angle


func can_move() -> bool:
	if !interacting or (lockAfterActivating and leverActivated):
		return false
	
	return true


@rpc("any_peer", "call_local", "unreliable")
func lock_handle_up():
	lever_activated.emit()
	
	leverFlipPlayer.play()
	leverActivated = true
	interacting = false


@rpc("any_peer", "call_local", "unreliable")
func lock_handle_down():
	lever_deactivated.emit()
	
	leverFlipPlayer.play()
	leverActivated = false
	interacting = false
