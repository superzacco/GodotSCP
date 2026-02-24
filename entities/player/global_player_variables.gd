extends Node


# MANAGERS / CONTROLS / UTIL
var interactionText: InteractionText
var facilityManager: FacilityManager
var interactionScript: Interaction
var spectatorManager: SpectatorManager
var ambienceManager: AmbienceManager
var debugInfo: DebugInfo


# player related
var player: Player
var playerPosition: Vector3 

var lookingEnabled: bool = true

var sprintJuice: float = 100
var blinkJuice: float = 100
var sensitivity: float = 0.67

var nearbyRoomLights: Array[RoomLight]
var inPocketDimension: bool = false



# INVENTORY
var interactionSprite: Sprite3D
var inventory: Inventory
var hoveredSlot: InventorySlot



# CONSOLE VARIABLES
var worldEnv: WorldEnvironment

var consoleOpen: bool = false
var immutableMenuOpen: bool = false

var noclipEnabled: bool = false
var godEnabled: bool = false
var blinkingEnabled: bool = true
var roomCullingEnabled: bool = true

var blinking: bool = false


# MULTIPLAYER
var playersBlinkingIDs: Array[int]

var usePTT: bool = true
@export var playersBlinking: Array[bool]
@export var OnScreen173: Array[bool]

@rpc("reliable", "call_local", "any_peer")
func update_blinking(id: int, blinking: bool):
	if is_multiplayer_authority():
		var idx = playersBlinkingIDs.find(id)
		playersBlinking[idx] = blinking

@rpc("reliable", "call_local", "any_peer")
func add_blinking(id: int, blinking: bool = false):
	if !playersBlinkingIDs.has(id):
		playersBlinkingIDs.append(id)
		playersBlinking.append(blinking)
	
	playersBlinkingIDs.sort()
