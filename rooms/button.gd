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
		return
	
	if buttonType == 1:
		var equippedKeycard: Keycard = get_keycard()
		
		if !equipped_item_is_keycard():
			SignalBus.show_interaction_text.emit("You need a keycard to open this door.")
			$Button.play()
			return
		
		GlobalPlayerVariables.inventory.clear_equip()
		
		if !equippedKeycard.keycardLevel >= keycardLevel:
			SignalBus.show_interaction_text.emit("You need a higher level keycard to open this door.")
			$Fail.play()
			return
		
		activate_things.rpc()


func equipped_item_is_keycard() -> bool:
	var item: Item = GlobalPlayerVariables.inventory.equippedItem
	
	if item == null:
		return false
	
	if item.itemType != item.ItemType.type_card:
		return false
	
	return true


func get_keycard() -> Keycard:
	var item: Item = GlobalPlayerVariables.inventory.equippedItem
	
	if item == null:
		return null
	if item.itemType != item.ItemType.type_card:
		return null
	
	var keycard: Keycard = item.functionItem
	
	if keycard == null:
		return null
	
	return keycard


@rpc("reliable", "call_local", "any_peer")
func activate_things():
	$Sound.play()
	if extraToControl != null:
		extraToControl.activate()
	
	for door: Door in doorsToControl:
		door.toggle_door.rpc()
