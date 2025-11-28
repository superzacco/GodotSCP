extends StaticBody3D
class_name Lever

@export var handle: MeshInstance3D

@export var canMove: bool = false
var movingHandle: bool = false

var leverActivated: bool = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		movingHandle = true
	if event.is_action_released("interact"):
		movingHandle = false
	
	if event is InputEventMouseMotion:
		if movingHandle == true and canMove == true:
			handle.rotation.x += (-event.relative.y * 0.0075)


func _physics_process(delta: float) -> void:
	if canMove:
		handle.rotation_degrees.x = clamp(handle.rotation_degrees.x, 2.0, 178.0)
	
	if handle.rotation_degrees.x > 150.0:
		lock_handle_up()
	if handle.rotation_degrees.x < 30.0:
		lock_handle_down()
	
	if !movingHandle:
		if leverActivated:
			handle.rotation_degrees.x = lerp(handle.rotation_degrees.x, 175.0, .1)
		else:
			handle.rotation_degrees.x = lerp(handle.rotation_degrees.x, 5.0, .1)
		
		return
	

func interact():
	print("j")
	canMove = true


func can_move() -> bool:
	if !leverActivated:
		return true
	
	return false

func lock_handle_up():
	leverActivated = true
func lock_handle_down():
	leverActivated = false
