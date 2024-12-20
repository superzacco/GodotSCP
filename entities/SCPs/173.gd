extends CharacterBody3D

@export var speed: float
var onScreen: bool = false

var player: RigidBody3D

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player") # 173 will need to get CLOSEST player at some point


func _on_visible_on_screen_notifier_3d_screen_entered() -> void:
	onScreen = true


func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
	onScreen = false


func _physics_process(delta: float) -> void:
	if !onScreen or GlobalPlayerVariables.blinking:
		$NavigationAgent3D.target_position = player.global_position
		var destination = $NavigationAgent3D.get_next_path_position()
		var localDestination = destination - global_position
		var moveDir = localDestination.normalized()
		velocity = (moveDir * speed)
		print(velocity)
		move_and_slide()
		
		self.look_at($NavigationAgent3D.target_position)
		self.rotation.x = 0
		self.rotation.z = 0
	
