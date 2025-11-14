extends Marker3D
class_name PDReleasePoint

@export var weight: int

func _ready() -> void:
	await SignalBus.level_generation_finished
	SignalBus.setup_pd_release_point.emit(self)
