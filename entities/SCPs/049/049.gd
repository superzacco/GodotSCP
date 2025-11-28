extends CharacterBody3D

@export var speed: int

@export var modelAnimations: AnimationPlayer
@export var agent: NavigationAgent3D


func _ready() -> void:
	modelAnimations.play("walk")


var nextPathPos := Vector3.ZERO
func _physics_process(delta: float) -> void:
	await SignalBus.level_generation_finished
	
	agent.target_position = find_closest_player().global_position
	nextPathPos = agent.get_next_path_position() - global_position
	velocity = (nextPathPos.normalized() * (speed * 0.1))
	move_and_slide()
	
	self.look_at(agent.get_next_path_position())
	self.rotation.x = 0
	self.rotation.z = 0


func find_closest_player() -> Player:
	var closestDist: float = INF
	var closestPlayer: Player
	
	var players = get_tree().get_nodes_in_group("player")
	
	for player: Player in players:
		var dist: float = self.global_position.distance_to(player.global_position)
		
		if dist < closestDist:
			closestDist = dist
			closestPlayer = player
	
	return closestPlayer
