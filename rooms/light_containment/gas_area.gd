extends Area3D

@export var enabled: bool = false

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and enabled:
		GlobalPlayerVariables.blinkQuickened = true

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player") and enabled:
		await get_tree().create_timer(4).timeout
		GlobalPlayerVariables.blinkQuickened = false
