extends Node

var consoleOpen: bool = false
var canMove: bool = true

var sprintJuice: float = 100
var blinkJuice: float = 100

# CONSOLE VARIABLES
var noclipEnabled: bool = false
var blinkingEnabled: bool = false
var blinkSpriteEnabled: bool = false

var blinking: bool = false


func _ready() -> void:
	if OS.is_debug_build():
		blinkSpriteEnabled = true
