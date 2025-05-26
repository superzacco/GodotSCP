extends StaticBody3D
class_name ConnectionPoint

var nearestConnectionPoint: Node3D

func _on_area_3d_body_entered(body: Node3D) -> void:
	nearestConnectionPoint = body
