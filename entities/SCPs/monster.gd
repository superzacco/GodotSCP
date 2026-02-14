extends CharacterBody3D
class_name Monster

@export var enabled: bool = false

var playersInChaseRadius: Array[Player] = []
var playersInAttackArea: Array[Player] = []

@export var speed: float
@export var animationSpeed: float = 1.0

@export var timer: Timer
@export var modelAnimations: AnimationPlayer
@export var agent: NavigationAgent3D

@export var chaseArea: Area3D
@export var attackArea: Area3D

func _ready() -> void:
	chaseArea.body_entered.connect(_on_chase_area_body_entered)
	chaseArea.body_exited.connect(_on_chase_area_body_exited)
	
	attackArea.body_entered.connect(_on_attack_area_body_entered)
	attackArea.body_exited.connect(_on_attack_area_body_exited)
	
	timer.timeout.connect(process_one)
	
	modelAnimations.speed_scale = animationSpeed


var nextPathPos := Vector3.ZERO
func process_one() -> void:
	if !should_process(): return
	
	nextPathPos = agent.get_next_path_position() - global_position
	velocity = (nextPathPos.normalized() * (speed * 0.1))


func _process(delta: float) -> void:
	if !should_process(): return
	
	agent.target_position = find_closest_player().global_position
	self.look_at(self.global_position + velocity)
	self.rotation.x = 0
	self.rotation.z = 0
	
	move_and_slide()


func should_process() -> bool:
	if !enabled or playersInChaseRadius.size() < 1 or find_closest_player() == null:
		return false
	
	return true


func set_active():
	enabled = true
	modelAnimations.play("walk")


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
		playersInChaseRadius.append(body)

func _on_chase_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		playersInChaseRadius.erase(body)

func _on_attack_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		playersInAttackArea.append(body)

func _on_attack_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		playersInAttackArea.erase(body)
