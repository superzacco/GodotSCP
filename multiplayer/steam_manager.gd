extends Node

var isOwned: bool = false
var steamAppID: int = 480  # Spacewar ID
var steamID: int = 0
var steamUsername: String = ""

var lobbyID = 0
var lobbyMaxPlayers = 4


func _init() -> void:
	print("Initializing Steam...")
	
	OS.set_environment("SteamAppId", str(steamAppID))
	OS.set_environment("SteamGameId", str(steamAppID))
	
	initialize_steam()


func _process(delta: float) -> void:
	Steam.run_callbacks()


func initialize_steam():
	var initialize_response: Dictionary = Steam.steamInitEx()
	
	if initialize_response['status'] > 0:
		print("Failed to initialize to Steam :( ... %s" % initialize_response)
		return
	
	isOwned = Steam.isSubscribed()
	steamID = Steam.getSteamID()
	steamUsername = Steam.getPersonaName()
	
	print("Hello " + str(steamUsername) + "!")
