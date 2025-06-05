extends Node

var mainMenu = preload("res://scenes/menu.tscn")
var devScene = preload("res://scenes/dev.tscn")
var facilityScene = preload("res://scenes/main.tscn")


func quit_to_menu():
	get_tree().change_scene_to_packed(mainMenu)
	Lobby.leave_lobby()
	pass
