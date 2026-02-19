extends Monster


func _ready() -> void:
	super()
	SignalBus.teleport_096_to_player.connect(teleport_to)



func teleport_to(pos: Vector3):
	self.global_position = pos
