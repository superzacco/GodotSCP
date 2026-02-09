extends Node3D

@export var doorsToControl: Array[Door]
@export var rejectionText: String
@export var wontOpen: bool = false
@export var disabled: bool = false

@export var extraToControl: Node3D

# button 0, keycardbutton 1
@export_enum("Button", "KeycardButton") var buttonType: int = 0
@export var keycardLevel: int = 0

func _ready() -> void:
	if disabled:
		queue_free()


func on_pressed():
	if extraToControl == null and doorsToControl.size() <= 0:
		push_error("Button with unassigned things")
		return
	
	if wontOpen:
		$Fail.play()
		SignalBus.show_interaction_text.emit(rejectionText)
		return
	
	if buttonType == 0:
		activate_things.rpc()
		
	elif buttonType == 1:
		var equippedKeycard: Keycard
		
		if GlobalPlayerVariables.inventory.equippedItem == null:
			SignalBus.show_interaction_text.emit("You need a keycard to open this door.")
			$Button.play()
			
		elif GlobalPlayerVariables.inventory.equippedItem.functionItem != null:
			equippedKeycard = GlobalPlayerVariables.inventory.equippedItem.functionItem
			
			if !equippedKeycard.keycardLevel >= keycardLevel:
				SignalBus.show_interaction_text.emit("You need a keycard to open this door.")
				$Fail.play()
				
			else:
				activate_things.rpc()
			
			GlobalPlayerVariables.inventory.clear_equip()


@rpc("reliable", "call_local", "any_peer")
func activate_things():
	$Sound.play()
	if extraToControl != null:
		extraToControl.activate()
	
	for door: Door in doorsToControl:
		door.toggle_door.rpc()
