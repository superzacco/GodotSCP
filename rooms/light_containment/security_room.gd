extends Room

var facility: FacilityManager = null


func _ready() -> void:
	facility = GlobalPlayerVariables.facilityManager


func checkpoint_unlock_lever_flipped():
	facility.unlock_heavy_containment_lockdown.rpc()
