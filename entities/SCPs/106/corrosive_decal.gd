class_name CorrosiveDecal
extends Area3D


var speed := 1.0
var finalSize := 1.0


func _ready() -> void:
	self.rotation_degrees.y = randi_range(0, 360)
	
	await get_tree().create_timer(60).timeout
	self.queue_free()


func _physics_process(delta: float) -> void:
	if self.scale.length() < finalSize:
		self.scale += Vector3(0.002, 0.002, 0.002) * speed
