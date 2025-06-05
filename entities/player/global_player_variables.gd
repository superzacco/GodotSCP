extends Node


# MANAGERS / CONTROLS / UTIL
var interactionText: InteractionText
var facilityManager: FacilityManager
var interactionScript: Interaction
var spectatorManager: SpectatorManager


# EXPLICITLY player related
var player: Player
var playerPosition: Vector3 

var lookingEnabled: bool = true

var sprintJuice: float = 100
var blinkJuice: float = 100
var sensitivity: float = 0.5




# INVENTORY
var inventory: Inventory
var hoveredSlot: InventorySlot



# CONSOLE VARIABLES
var worldEnv: WorldEnvironment

var consoleOpen: bool = false

var noclipEnabled: bool = false
var blinkingEnabled: bool = true
var blinkSpriteEnabled: bool = true

var blinking: bool = false
