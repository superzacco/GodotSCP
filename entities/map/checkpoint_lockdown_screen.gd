extends SecurityMonitor

@export var screenSprite: AnimatedSprite3D
var facility: FacilityManager = null

func _ready() -> void:
	facility = GlobalPlayerVariables.facilityManager
	facility.hcon_checkpoints_unlock.connect(disable_screen)


func disable_screen():
	if screenSprite != null:
		screenSprite.queue_free()
