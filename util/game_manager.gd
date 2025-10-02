extends Node

var startingCell
var rng: RandomNumberGenerator
var seed: int

var gameTime: float
var gameStarted: bool = false

var mainMenu: PackedScene = load("res://scenes/menu.tscn")
var devScene : PackedScene = load("res://scenes/dev.tscn")
var facilityScene: PackedScene = load("res://scenes/main.tscn")


func _ready() -> void:
	seed = randi_range(-999999999, 999999999)
	
	rng = RandomNumberGenerator.new()
	rng.seed = seed
	
	print(seed)


func quit_to_menu():
	gameStarted = false
	get_tree().change_scene_to_packed(mainMenu)
	Lobby.leave_lobby()


func _physics_process(delta: float) -> void:
	if gameStarted:
		gameTime += delta


func clear_state():
	GlobalPlayerVariables.blinkingEnabled = true
	GlobalPlayerVariables.consoleOpen = false
	GlobalPlayerVariables.lookingEnabled = true
	GlobalPlayerVariables.roomCullingEnabled = true
	GlobalPlayerVariables.immutableMenuOpen = false
	
	if GlobalPlayerVariables.noclipEnabled:
		Commands.noclip()


@rpc("call_local", "any_peer")
func game_start():
	if gameStarted:
		return
	
	SignalBus.emit_signal("generate_level")
	startingCell.on_start_game()
	gameStarted = true


func game_win():
	gameStarted = false
	var finalTime: String = str(gameTime)
	var decimalIdx = finalTime.find(".")
	
	if decimalIdx > 0:
		finalTime = finalTime.left(decimalIdx + 3)
	
	SignalBus.emit_signal("win_game", finalTime)
