extends Node

var mainMenu: PackedScene = load("res://scenes/menu.tscn")
var devScene : PackedScene = load("res://scenes/dev.tscn")
var facilityScene: PackedScene = load("res://scenes/main.tscn")


func quit_to_menu():
	get_tree().change_scene_to_packed(mainMenu)
	Lobby.leave_lobby()
	pass
