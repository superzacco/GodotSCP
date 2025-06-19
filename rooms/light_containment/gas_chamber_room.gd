extends Room

@export var gasEmitters: Array[GPUParticles3D]
@export var doors: Array[Door]
var running: bool = false

func activate():
	if running:
		for door in doors:
			door.close()
		return
	
	for door in doors:
		door.open()
	running = true
	
	await get_tree().create_timer(4).timeout
	$AlarmPlayer.play()
	await get_tree().create_timer(1.8).timeout
	
	for door in doors:
		door.close()
	running = false


func _on_room_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		for emitter: GPUParticles3D in gasEmitters:
			emitter.emitting = true
func _on_room_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		for emitter: GPUParticles3D in gasEmitters:
			emitter.emitting = false
