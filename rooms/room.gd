extends Node3D
class_name Room

@export var roomName: String

@export var spawnPosFor173: Node3D
@export var can173Spawn: bool = true

@export var chanceForEvent: float = 0.0
@export var addSelfToFacility: bool = false

var facilityMGR: FacilityManager = null

func _init() -> void:
	self.add_to_group("room")


func _ready() -> void:
	await SignalBus.level_generation_finished
	facilityMGR = await GlobalPlayerVariables.get_facility_manager()
	
	if addSelfToFacility:
		facilityMGR.rooms.append(self)


func return_173_spawn_point_position() -> Vector3:
	if spawnPosFor173 != null:
		return spawnPosFor173.global_position
	
	return self.global_position

func return_173_spawn_point() -> Node3D:
	if spawnPosFor173 != null:
		return spawnPosFor173
	
	return self
