extends RigidBody3D

@export var stuffToRotate: Node3D
@export var collider: CollisionShape3D
@export var camera: Camera3D

@export var sensitivityDesired: float
@export var moveSpeedDesired: float
var sensitivity: float
var moveSpeed: float

var wishDir: Vector3
var noclip_enabled: bool = false

func _ready() -> void:
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_CAPTURED)
	if !is_multiplayer_authority():
		camera.queue_free()
	
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_CAPTURED)
	get_parent().get_node("UI/Console").connect("toggle_noclip", toggle_noclip)
	pass


func _physics_process(_delta: float) -> void:
	if !is_multiplayer_authority():
		return
	
	linear_velocity *= 0.85
	
	moveSpeed = 0.0 if GlobalVariables.consoleOpen else moveSpeedDesired
	sensitivity = 0.0 if GlobalVariables.consoleOpen else sensitivityDesired
	
	#region MOVEMENT
	var moveDir: Vector3 
	wishDir.x = Input.get_axis("right", "left")
	wishDir.z = Input.get_axis("back", "forward")
	
	if !noclip_enabled:
		moveDir = stuffToRotate.basis.z * wishDir.z + stuffToRotate.basis.x * wishDir.x
	else:
		moveDir = -camera.global_basis.z * wishDir.z + -camera.global_basis.x * wishDir.x
		if Input.is_action_pressed("blink"):
			apply_force(stuffToRotate.transform.basis.y * moveSpeed)
	
	apply_force(moveDir.normalized() * moveSpeed)
	pass


#region CAMERA MOVEMENT
func _input(event):
	if event is InputEventMouseMotion:
		stuffToRotate.rotate_y(deg_to_rad(-event.relative.x * sensitivity * 0.1))
		camera.rotate_x(deg_to_rad(-event.relative.y * sensitivity * 0.1))
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	
	if Input.is_action_just_pressed("noclip"):
		toggle_noclip()
pass
#endregion


func toggle_noclip():
	if noclip_enabled:
		gravity_scale = 1
		collider.disabled = false
		noclip_enabled = false
		print("noclip OFF")
	elif !noclip_enabled:
		gravity_scale = 0
		collider.disabled = true
		noclip_enabled = true
		print("noclip ON")
	pass
