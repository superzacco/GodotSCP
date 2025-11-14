extends Node
class_name FacilityManager

var rooms: Array
var playerNearbyRooms: Array[Room]

var scp173: CharacterBody3D
var scp106: CharacterBody3D


func _ready() -> void:
	GlobalPlayerVariables.facilityManager = self 
	flicker_nearby_lights()


func flicker_nearby_lights():
	$LightTimer.start(randf_range(30, 90))
	await $LightTimer.timeout
	
	var playerNearbyLights = GlobalPlayerVariables.nearbyRoomLights
	if playerNearbyLights.size() != 0:
		playerNearbyLights[randi_range(0, playerNearbyLights.size()-1)].start_flicker()
		if ZFunc.randInPercent(50):
			playerNearbyLights[randi_range(0, playerNearbyLights.size()-1)].start_flicker()
		
		flicker_nearby_lights()


func flicker_all_nearby_lights():
	for light: RoomLight in GlobalPlayerVariables.nearbyRoomLights:
		if light != null and light.canFlicker:
			light.start_flicker()
