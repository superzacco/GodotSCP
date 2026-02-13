extends CharacterBody3D

var playersInRadius: Array[Player] = []

var enabled: bool = false
@export var speed: int

@export var timer: Timer
@export var modelAnimations: AnimationPlayer
@export var agent: NavigationAgent3D


func _ready() -> void:
	timer.timeout.connect(process_one)
	
	modelAnimations.speed_scale = 1.5
	modelAnimations.play("walk")
	
	await SignalBus.level_generation_finished
	enabled = true


var nextPathPos := Vector3.ZERO
func process_one() -> void:
	if !enabled or playersInRadius.size() < 1:
		return
	
	nextPathPos = agent.get_next_path_position() - global_position
	velocity = (nextPathPos.normalized() * (speed * 0.1))
	


func _process(delta: float) -> void:
	agent.target_position = find_closest_player().global_position
	self.look_at(nextPathPos)
	self.rotation.x = 0
	self.rotation.z = 0
	
	move_and_slide()


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


func _on_chase_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		playersInRadius.append(body)

func _on_chase_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		playersInRadius.append(body)
