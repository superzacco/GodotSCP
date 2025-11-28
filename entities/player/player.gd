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

@export var playerModel: Node3D
@export var modelAnimations: AnimationPlayer

@export var bodyslump: AudioStream
@export var deathsound_106: AudioStream

var moveSpeed: float

var wishDir: Vector3
var sprinting: bool = false

var blinking: bool = false

var health: float = 100.0
var dead: bool = false
var canMove: bool = true
var specMgr: SpectatorManager

var multiplayerAuthorityID: int 

var skeleton: Skeleton3D
var upperBodyBone
var headBone

func _ready() -> void:
	camera.current = is_multiplayer_authority()
	playerModel.visible = !is_multiplayer_authority()
	if !is_multiplayer_authority():
		$UI.hide()
		$UI.set_process(false)
		return
	
	skeleton = $StuffToRotate/classd001/Armature/Skeleton3D
	upperBodyBone = $StuffToRotate/classd001/Armature/Skeleton3D.find_bone("bodyupper")
	headBone = $StuffToRotate/classd001/Armature/Skeleton3D.find_bone("head")
	
	GlobalPlayerVariables.player = self
	GameManager.clear_state()
	specMgr = GlobalPlayerVariables.spectatorManager
	
	moveSpeed = moveSpeedDesired
	
	$AnimationPlayer.play("walking_Bob")
	$AnimationPlayer.pause()
	
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_CAPTURED)


func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		blinking = GlobalPlayerVariables.blinking
	
	if !is_multiplayer_authority() or dead or !canMove:
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
		
		var speedMultiplier
		if Input.is_action_pressed("crouch"):
			speedMultiplier = 0.1
		else:
			speedMultiplier = 0.5
		if Input.is_action_pressed("blink"):
			apply_force(stuffToRotate.transform.basis.y * (moveSpeed * speedMultiplier) * 10)
		
		self.position += (moveDir.normalized() * (moveSpeed * speedMultiplier)) * delta 
	
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
	
	#region // ANIMATIONS
	if moveDir != Vector3(0, 0, 0) and !GlobalPlayerVariables.consoleOpen:
		$AnimationPlayer.play()
		
		if sprinting and GlobalPlayerVariables.sprintJuice > 0:
			#modelAnimations.play("run")
			pass
		else:
			modelAnimations.play("walk")
	else:
		$AnimationPlayer.pause()
		modelAnimations.play("idle")
	#endregion

#region CAMERA MOVEMENT
func _input(event):
	if GlobalPlayerVariables.consoleOpen or !is_multiplayer_authority() or dead:
		return
	
	if event is InputEventMouseMotion and GlobalPlayerVariables.lookingEnabled:
		stuffToRotate.rotate_y(deg_to_rad(-event.relative.x * GlobalPlayerVariables.sensitivity * 0.1))
		camera.rotate_x(deg_to_rad(-event.relative.y * GlobalPlayerVariables.sensitivity * 0.1))
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))
		
		#skeleton.set_bone_pose_rotation(upperBodyBone, Quaternion(camera.rotation.x, 0, 0, 1))
	
	if Input.is_action_just_pressed("noclip"):
		toggle_noclip()
	
	if Input.is_action_just_pressed("sprint"):
		sprinting = true
	
	if Input.is_action_just_released("sprint"):
		sprinting = false
#endregion


func toggle_noclip():
	if GlobalPlayerVariables.noclipEnabled:
		gravity_scale = 10
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


func sent_to_pocket_dimension():
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		return
	
	$AnimationPlayer.play("death")
	
	play_death_sound(deathsound_106)
	#GlobalPlayerVariables.ambienceManager.play_sound(deathsound_106)
	
	canMove = false
	print("test %s , %s" % [get_multiplayer_authority(), multiplayer.get_unique_id()])
	GlobalPlayerVariables.lookingEnabled = false
	
	await get_tree().create_timer(0.4)
	$BodySlumpPlayer.play()
	
	await get_tree().create_timer(2.5).timeout
	SignalBus.send_player_to_106.emit(self)
	
	$AnimationPlayer.stop()
	$AnimationPlayer.play("walking_Bob")
	
	canMove = true
	GlobalPlayerVariables.lookingEnabled = true


func take_damage(damage: float, typeOfDamage: String = ""):
	health -= damage
	
	match typeOfDamage:
		"106":
			sent_to_pocket_dimension()
	
	if health <= 0.0:
		on_death.rpc(self.get_multiplayer_authority()) # Add types later
	
	print("player: %s took %s damage!" % [get_multiplayer_authority(), damage])
	print("player: %s health now %s." % [get_multiplayer_authority(), health])


@rpc("any_peer", "call_local", "reliable")
func on_death(dyingPLayerID: int):
	var selfID: int = multiplayer.get_unique_id()
	
	if dyingPLayerID == selfID:
		canMove = false
		$AnimationPlayer.play("death")
	
	modelAnimations.play("death")
	
	await get_tree().create_timer(0.45).timeout
	$BodySlumpPlayer.play()
	
	await modelAnimations.animation_finished
	modelAnimations.play("dead")
	
	await get_tree().create_timer(2.5).timeout
	print("dying player id: %s -- id runing code: %s" % [dyingPLayerID, selfID])
	
	if dyingPLayerID == selfID:
		print("this should not show up twice")
		specMgr.switch_player_to_spectator(dyingPLayerID)
	
	print("player: %s has died!" % dyingPLayerID)
	SignalBus.remove_player.emit(dyingPLayerID)


func play_death_sound(stream: AudioStream):
	$DeathSounds.stream = stream
	$DeathSounds.play()



func return_nearby_rooms():
	var rooms = []
	
	for area: Area3D in $NearbyRooms.get_overlapping_areas():
		if area.is_in_group("room"):
			rooms.append(area.get_parent())
	
	return rooms
