extends Area3D


@export var spawnPoints: Dictionary[Node3D, int]


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		GlobalPlayerVariables.inPocketDimension = true


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		GlobalPlayerVariables.inPocketDimension = false
