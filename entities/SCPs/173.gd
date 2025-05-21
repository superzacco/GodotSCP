extends CharacterBody3D

@export var speed: float
var onScreen: bool = false

var player: RigidBody3D
@export var agent: NavigationAgent3D

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player") # 173 will need to get CLOSEST player at some point


func _on_visible_on_screen_notifier_3d_screen_entered() -> void:
	onScreen = true
func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
	onScreen = false


func _physics_process(delta: float) -> void:
	if !onScreen or GlobalPlayerVariables.blinking:
		var nextPathPos: Vector3
		
		agent.target_position = player.global_position
		nextPathPos = agent.get_next_path_position() - global_position
		velocity = (nextPathPos.normalized() * speed)
		
		move_and_slide()
		
		self.look_at(agent.target_position)
		self.rotation.x = 0
		self.rotation.z = 0
	
