extends Area3D


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		trigger_173.rpc()

@rpc("any_peer", "call_local", "reliable")
func trigger_173():
	if multiplayer.is_server():
		SignalBus.activate_173.emit()
	
	self.queue_free()
