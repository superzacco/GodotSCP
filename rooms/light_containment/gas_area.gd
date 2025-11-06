extends Area3D

@export var enabled: bool = false
var inArea: bool = false

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and enabled:
		inArea = true


func _physics_process(delta: float) -> void:
	if inArea and !GlobalPlayerVariables.wearingGasMask:
		GlobalPlayerVariables.blinkQuickened = true
	else:
		GlobalPlayerVariables.blinkQuickened = false


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player") and enabled:
		await get_tree().create_timer(4).timeout
		inArea = false
