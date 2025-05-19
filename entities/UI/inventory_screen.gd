extends Control
class_name Inventory

@export var dropArea: Control
@export var slotsNode: GridContainer

var slots: Array[InventorySlot]
var inventoryOpen: bool = false

var clickHeld: bool = false
var overDropArea: bool = false

var heldItem: Item
var heldItemIdx: int

var currentSlot: InventorySlot
var currentSlotIcon: TextureRect
var iconOriginPoint: Vector2

func _ready() -> void:
	for i in slotsNode.get_children().size():
		slots.append(slotsNode.get_child(i))
	
	GlobalPlayerVariables.inventory = self


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("inventory"):
		if inventoryOpen:
			DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_CAPTURED)
			GlobalPlayerVariables.lookingEnabled = true
			
			self.hide()
			inventoryOpen = false
		else:
			DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)
			GlobalPlayerVariables.lookingEnabled = false
			
			self.show()
			inventoryOpen = true
	
	
	if Input.is_action_just_pressed("interact") and inventoryOpen:
		if GlobalPlayerVariables.hoveredSlot != null:
			heldItemIdx = GlobalPlayerVariables.hoveredSlot.get_index()
			
			currentSlot = slots[heldItemIdx]
			heldItem = currentSlot.heldItem
			currentSlotIcon = currentSlot.slotIcon
			iconOriginPoint = currentSlotIcon.global_position
		
		clickHeld = true
	
	if Input.is_action_just_released("interact"):
		if currentSlotIcon != null:
			currentSlotIcon.global_position = iconOriginPoint
		
		if heldItem != null and overDropArea:
			on_drop_item(heldItem, currentSlot)
		
		clickHeld = false
		currentSlot = null
		currentSlotIcon = null
		heldItem = null


func _process(delta: float) -> void:
	if !clickHeld:
		return
	
	var mousePosition: Vector2 = get_global_mouse_position()
	if currentSlotIcon != null:
		currentSlotIcon.global_position = Vector2(mousePosition.x - (currentSlotIcon.size.x/2), mousePosition.y - (currentSlotIcon.size.y/2))


func on_pickup_item(item: Item):
	for i in slots.size():
		if slots[i].heldItem == null:
			slots[i].heldItem = item
			
			slots[i].slotIcon.texture = item.inventorySprite
			slots[i].slotText.text = item.inventoryName
			break


func on_drop_item(item: Item, slot: InventorySlot):
	var randomPos = Vector3(randf_range(-0.25, 0.25), 1, randf_range(-0.25, 0.25))
	var randomRotation = randi_range(0, 360)
	
	slot.heldItem.global_position = GlobalPlayerVariables.playerPosition + randomPos
	slot.heldItem.global_rotation.y = randomRotation
	slot.heldItem.reparent(get_tree().root)
	slot.heldItem.freeze = false
	
	slot.heldItem = null
	slot.slotIcon.texture = null
	slot.slotText.text = ""




func _on_slots_mouse_entered() -> void:
	overDropArea = false
func _on_slots_mouse_exited() -> void:
	overDropArea = true
