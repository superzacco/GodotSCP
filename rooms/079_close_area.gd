extends Area3D


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		if ZFunc.randInPercent(2):
			var door: Door = get_parent()
			if door.doorOpen == true:
				door.scp_079_close.rpc()
