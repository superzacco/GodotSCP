extends Node

var consoleOpen: bool = false
var lookingEnabled: bool = true

var playerPosition: Vector3 
var sprintJuice: float = 100
var blinkJuice: float = 100


# INVENTORY

var inventory: Inventory
var hoveredSlot: InventorySlot


# CONSOLE VARIABLES
var noclipEnabled: bool = false
var blinkingEnabled: bool = true
var blinkSpriteEnabled: bool = true

var blinking: bool = false
