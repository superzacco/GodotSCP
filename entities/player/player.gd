extends RigidBody3D
class_name Player

@export var stuffToRotate: Node3D
@export var collider: CollisionShape3D
@export var camera: Camera3D

@export var moveSpeedDesired: float
@export var sprintSpeedDesired: float

@export var sprintDepletionRate: float
@export var sprintReplenishRate: float

@export var blinkinator: PlayerBlinking

var sensitivity: float
var moveSpeed: float

var wishDir: Vector3
var sprinting: bool = false

var multiplayerAuthorityID: int 

func _ready() -> void:
	print(multiplayerAuthorityID)
	camera.current = is_multiplayer_authority()
	
	GlobalPlayerVariables.player = self
	
	moveSpeed = moveSpeedDesired
	sensitivity = GlobalPlayerVariables.sensitivity
	
	$AnimationPlayer.play("walking_Bob")
	$AnimationPlayer.pause()
	
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_CAPTURED)


func _physics_process(delta: float) -> void:
	if !is_multiplayer_authority():
		return
	if GlobalPlayerVariables.consoleOpen:
		moveSpeed = 0.0
	
	#region MOVEMENT
	linear_velocity *= 0.85
	
	var moveDir: Vector3 
	wishDir.x = Input.get_axis("right", "left")
	wishDir.z = Input.get_axis("back", "forward")
	
	if !GlobalPlayerVariables.noclipEnabled:
		moveDir = -(stuffToRotate.global_basis.z * wishDir.z + stuffToRotate.global_basis.x * wishDir.x)
		self.position += (moveDir.normalized() * moveSpeed) * delta * 0.1
	else:
		moveDir = -camera.global_basis.z * wishDir.z + -camera.global_basis.x * wishDir.x
		self.position += (moveDir.normalized() * moveSpeed) * delta * 0.5
		if Input.is_action_pressed("blink"):
			apply_force(stuffToRotate.transform.basis.y * moveSpeed * 5)
	
	GlobalPlayerVariables.playerPosition = self.global_position
	#endregion
	

	#region SPRINTING
	if GlobalPlayerVariables.sprintJuice > 0 and sprinting and moveDir != Vector3(0, 0, 0):
		moveSpeed = sprintSpeedDesired
		GlobalPlayerVariables.sprintJuice -= sprintDepletionRate * delta
	else:
		moveSpeed = moveSpeedDesired
	
	# recharge
	if !sprinting and GlobalPlayerVariables.sprintJuice < 100:
		recharge_sprint(delta)
	
	if sprinting and GlobalPlayerVariables.sprintJuice > 0:
		$AnimationPlayer.speed_scale = 1.35
	else:
		$AnimationPlayer.speed_scale = 1 
	#endregion
	
	if moveDir != Vector3(0, 0, 0) and !GlobalPlayerVariables.consoleOpen:
		$AnimationPlayer.play()
	else:
		$AnimationPlayer.pause()


#region CAMERA MOVEMENT
func _input(event):
	if GlobalPlayerVariables.consoleOpen or !is_multiplayer_authority():
		return
	
	if event is InputEventMouseMotion and GlobalPlayerVariables.lookingEnabled:
		stuffToRotate.rotate_y(deg_to_rad(-event.relative.x * sensitivity * 0.1))
		camera.rotate_x(deg_to_rad(-event.relative.y * sensitivity * 0.1))
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	
	if Input.is_action_just_pressed("noclip"):
		toggle_noclip()
	
	if Input.is_action_just_pressed("sprint"):
		sprinting = true
	
	if Input.is_action_just_released("sprint"):
		sprinting = false
#endregion


func toggle_noclip():
	if GlobalPlayerVariables.noclipEnabled:
		gravity_scale = 1
		collider.disabled = false
		GlobalPlayerVariables.noclipEnabled = false
		GlobalPlayerVariables.blinkingEnabled = true
		Commands.console.println("noclip OFF")
		print("noclip OFF")
	else:
		gravity_scale = 0
		collider.disabled = true
		GlobalPlayerVariables.noclipEnabled = true
		GlobalPlayerVariables.blinkingEnabled = false
		Commands.console.println("noclip ON")
		print("noclip ON")


func recharge_sprint(delta): # FIX THE TIMER NOT BEING RESET 
	await get_tree().create_timer(2).timeout
	if !sprinting and GlobalPlayerVariables.sprintJuice < 100:
		GlobalPlayerVariables.sprintJuice += sprintReplenishRate * delta
	
	if GlobalPlayerVariables.sprintJuice > 100:
		GlobalPlayerVariables.sprintJuice = 100


func on_death():
	collider.disabled = true
	GlobalPlayerVariables.spectatorManager.switch_player_to_spectator(multiplayerAuthorityID)
	queue_free()
