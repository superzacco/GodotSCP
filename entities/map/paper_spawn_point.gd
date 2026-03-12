extends Marker3D

var facility: FacilityManager = null

@export var type: PaperType = PaperType.TO_BE_DETERMINED
enum PaperType {
	NOTE_HCON_CHECKPOINT,
	TO_BE_DETERMINED
}

func _ready() -> void:
	await SignalBus.facility_manager_ready
	
	facility = GlobalPlayerVariables.facilityManager
	match type:
		PaperType.NOTE_HCON_CHECKPOINT:
			facility.LConToHConPostitNoteSpawns.append(self.global_position)
		_:
			pass
