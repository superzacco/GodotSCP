extends Area3D

@export var enabled: bool = false
var playersInArea: Array[Player] = []


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and enabled:
		playersInArea.append(body)

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player") and enabled:
		await get_tree().create_timer(4).timeout
		body.blinkQuickened = false
		playersInArea.erase(body)


func _on_player_check_timeout() -> void:
	for player: Player in playersInArea:
		if !player.wearingGasMask:
			player.blinkQuickened = true
