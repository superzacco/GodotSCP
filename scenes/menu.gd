extends Control

@export var devScene: PackedScene
@export var mainScene: PackedScene


#region # BUTTONS
func _on_play_dev_pressed() -> void:
	get_tree().change_scene_to_packed(devScene)
	pass 


func _on_play_map_gen_test_pressed() -> void:
	get_tree().change_scene_to_packed(mainScene)
	pass


func _on_quit_pressed() -> void:
	get_tree().quit()
	pass 
#endregion
