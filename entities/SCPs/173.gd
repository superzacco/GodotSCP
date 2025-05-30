extends CharacterBody3D

@export var speed: float
@export var agent: NavigationAgent3D

var onScreen: bool = false
var nearPlayer: bool = false
var nearDoor: StaticBody3D 


func _on_visible_on_screen_notifier_3d_screen_entered() -> void:
	onScreen = true
func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
	onScreen = false


func _physics_process(delta: float) -> void:
	if (!onScreen or GlobalPlayerVariables.blinking) and nearPlayer :
		var nextPathPos: Vector3
		
		agent.target_position = GlobalPlayerVariables.playerPosition
		nextPathPos = agent.get_next_path_position() - position
		velocity = (nextPathPos.normalized() * speed)
		
		move_and_slide()
		
		self.look_at(agent.target_position)
		self.rotation.x = 0
		self.rotation.z = 0
		
		if !$StoneScraping.playing: # fires on the first frame
			$StoneScraping.play(randf_range(0.0, 5.0))
			if nearDoor != null and !waiting:
				try_break_door()
		
		return
	
	$StoneScraping.stop()


var waiting: bool = false
func try_break_door():
	waiting = true
	print("Trying to break through door!")
	
	await get_tree().create_timer(2).timeout
	waiting = false
	if randi_range(0, 3) == 0:
		if nearDoor != null:
			nearDoor.one_seven_three_open()
			print("Broke through door!")


func relocate():
	print("relocating!")
	
	var rooms = GlobalPlayerVariables.facilityManager.rooms
	var room = rooms[randi_range(0, rooms.size()-1)]
	
	if room != null and !room.position.distance_to(GlobalPlayerVariables.playerPosition) < 15:
		self.global_position = room.global_position + Vector3(0, 1, 0)
	
	if self.position.distance_to(GlobalPlayerVariables.playerPosition) < 40:
		print("close to player")
		
	else:
		$"3sRelocateTimer".start()
		await $"3sRelocateTimer".timeout
		relocate()


func _on_door_detection_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("door"):
		nearDoor = body
func _on_door_detection_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("door"):
		nearDoor = null


func _on_chase_radius_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		nearPlayer = true
		
		$"3sRelocateTimer".stop()
func _on_chase_radius_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		nearPlayer = false
		
		$"3sRelocateTimer".start()
		await $"3sRelocateTimer".timeout
		relocate()
