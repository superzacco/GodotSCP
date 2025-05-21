extends Node3D

@export var doorToControl: Node3D

# button 0, keycardbutton 1
@export_enum("Button", "KeycardButton") var buttonType: int = 0
@export var keycardLevel: int = 0
# Add type of button here later

func _ready() -> void:
	print(buttonType)

func on_pressed():
	if doorToControl == null:
		return
	
	if buttonType == 0:
		if doorToControl != null:
			doorToControl.toggle_door()
	elif buttonType == 1:
		var equippedKeycard: Keycard
		
		if GlobalPlayerVariables.inventory.equippedItem == null:
			print("You need a keycard to open this door.")
		elif GlobalPlayerVariables.inventory.equippedItem.functionItem != null:
			equippedKeycard = GlobalPlayerVariables.inventory.equippedItem.functionItem
			
			if equippedKeycard.keycardLevel >= keycardLevel:
				doorToControl.toggle_door()
			else:
				print("You need a higher level keycard to access this door.")
			
			GlobalPlayerVariables.inventory.clear_equip()
