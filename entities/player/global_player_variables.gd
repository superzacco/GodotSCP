extends Node


# MANAGERS / CONTROLS / UTIL
var interactionText: InteractionText
var facilityManager: FacilityManager
var interactionScript: Interaction
var spectatorManager: SpectatorManager
var ambienceManager: AmbienceManager


# EXPLICITLY player related
var player: Player
var playerPosition: Vector3 

var lookingEnabled: bool = true
var wearingGasMask: bool = false

var sprintJuice: float = 100
var blinkJuice: float = 100
var sensitivity: float = 0.67
var blinkQuickened: bool = false

var nearbyRoomLights: Array[RoomLight]



# INVENTORY
var interactionSprite: Sprite3D
var inventory: Inventory
var hoveredSlot: InventorySlot



# CONSOLE VARIABLES
var worldEnv: WorldEnvironment

var consoleOpen: bool = false
var immutableMenuOpen: bool = false

var noclipEnabled: bool = false
var blinkingEnabled: bool = true
var roomCullingEnabled: bool = true

var blinking: bool = false


# MULTIPLAYER
var ID: int
var playersBlinkingIDs: Array[int]

@export var playersBlinking: Array[bool]
@export var OnScreen173: Array[bool]

@rpc("call_local", "any_peer")
func update_blinking(id: int, blinking: bool):
	if is_multiplayer_authority():
		var idx = playersBlinkingIDs.find(id)
		playersBlinking[idx] = blinking

@rpc("call_local", "any_peer")
func add_blinking(id: int, blinking: bool = false):
	if !playersBlinkingIDs.has(id):
		playersBlinkingIDs.append(id)
		playersBlinking.append(blinking)
	
	playersBlinkingIDs.sort()
