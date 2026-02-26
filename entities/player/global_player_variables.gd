extends Node


# MANAGERS / CONTROLS / UTIL
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
var usePTT: bool = true
