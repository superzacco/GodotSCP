extends Node3D

@export var clickSounds: Array[AudioStream]
var texts: Dictionary[String, int] = {
	"Lil Marley has perished...": 10,
	"John Parrish has perished...": 10,
	"Zacco has perished...": 1,
	"Your mother has perished...": 25,
	"Your dog has perished...": 15,
	"Your dog has died...": 15,
	"Your cat has perished...": 15,
	"Your cat has died...": 15,
	"Your friend has prished...": 25,
	"Regalis has died...": 10,
	"You feel that someone you know has passed...": 50
}


func equip():
	GlobalPlayerVariables.interactionText.display(pick_from_list())
	GlobalPlayerVariables.ambienceManager.play_sound(clickSounds[randi_range(0, clickSounds.size()-1)])


func pick_from_list():
	var totalWeight: int
	
	for weight in texts.values():
		totalWeight +=  weight
	
	var randomWeight: int = randi_range(0, totalWeight-1)
	var currentWeight: int = 0
	
	for option in texts.keys():
		currentWeight += texts[option]
		if randomWeight < currentWeight:
			return option
