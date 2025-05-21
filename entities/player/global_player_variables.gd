extends Node

var player: Player
var playerPosition: Vector3 

var lookingEnabled: bool = true

var sprintJuice: float = 100
var blinkJuice: float = 100



# INVENTORY
var inventory: Inventory
var hoveredSlot: InventorySlot



# CONSOLE VARIABLES
var consoleOpen: bool = false

var noclipEnabled: bool = false
var blinkingEnabled: bool = true
var blinkSpriteEnabled: bool = true

var blinking: bool = false
