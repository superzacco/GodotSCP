extends Node3D

@export var doorsToControl: Array[Door]
@export var rejectionText: String
@export var wontOpen: bool

@export var extraToControl: Node3D

# button 0, keycardbutton 1
@export_enum("Button", "KeycardButton") var buttonType: int = 0
@export var keycardLevel: int = 0

func on_pressed():
	if extraToControl != null:
		extraToControl.activate()
	
	if doorsToControl.size() <= 0 or doorsToControl[0] == null:
		$Sound.play()
		return
	
	if wontOpen:
		$Fail.play()
		GlobalPlayerVariables.interactionText.display(rejectionText)
		return
	
	if buttonType == 0:
		open_door()
		$Sound.play()
	elif buttonType == 1:
		var equippedKeycard: Keycard
		
		if GlobalPlayerVariables.inventory.equippedItem == null:
			GlobalPlayerVariables.interactionText.display("You need a keycard to open this door.")
			$Button.play()
			
		elif GlobalPlayerVariables.inventory.equippedItem.functionItem != null:
			equippedKeycard = GlobalPlayerVariables.inventory.equippedItem.functionItem
			
			if !equippedKeycard.keycardLevel >= keycardLevel:
				GlobalPlayerVariables.interactionText.display("You need a higher level keycard to access this door.")
				$Fail.play()
				
			else:
				open_door()
				$Sound.play()
			
			GlobalPlayerVariables.inventory.clear_equip()


func open_door():
	for door in doorsToControl:
		door.toggle_door()
