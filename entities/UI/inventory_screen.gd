extends Control
class_name Inventory

@export var equippedItemFrame: TextureRect
var equippedItemIcon: TextureRect 

@export var slotsNode: GridContainer
var slots: Array[InventorySlot]

var inventoryOpen: bool = false
var clickHeld: bool = false
var overDropArea: bool = false

var equippedItem: Item
var heldItem: Item
var hoveredSlotIdx: int

var currentSlot: InventorySlot
var currentSlotIcon: TextureRect
var iconOriginPoint: Vector2

func _ready() -> void:
	for i in slotsNode.get_children().size():
		slots.append(slotsNode.get_child(i))
	
	GlobalPlayerVariables.inventory = self
	equippedItemFrame = $"../HeldItemFrame"
	equippedItemIcon = $"../HeldItemFrame/Item"


var clicki: int = 0

func _input(event: InputEvent) -> void:
	if !is_multiplayer_authority():
		return
	
	if Input.is_action_just_pressed("inventory"):
		if inventoryOpen:
			close_inventory()
		else:
			if GlobalPlayerVariables.immutableMenuOpen: return
			open_inventory()
	
	if Input.is_action_just_released("quit") and inventoryOpen :
		close_inventory()
	
	if Input.is_action_just_pressed("interact") and inventoryOpen:
		if GlobalPlayerVariables.hoveredSlot != null:
			hoveredSlotIdx = GlobalPlayerVariables.hoveredSlot.get_index()
			
			currentSlot = slots[hoveredSlotIdx]
			currentSlotIcon = currentSlot.slotIcon
			
			heldItem = currentSlot.heldItem
			iconOriginPoint = currentSlotIcon.global_position
		
		clickHeld = true
	
	if Input.is_action_just_released("interact"):
		if currentSlotIcon != null:
			currentSlotIcon.global_position = iconOriginPoint
		
		if heldItem != null and overDropArea and inventoryOpen:
			on_drop_item(currentSlot)
		
		if GlobalPlayerVariables.hoveredSlot != null and heldItem != null:
			swap_item(currentSlot, GlobalPlayerVariables.hoveredSlot)
		
		clickHeld = false
		currentSlot = null
		currentSlotIcon = null
		heldItem = null
	
	if event.is_action_pressed("interact") and inventoryOpen:
		clicki += 1
		await  get_tree().create_timer(0.25).timeout
		if clicki >= 2 and GlobalPlayerVariables.hoveredSlot != null:
			var item = GlobalPlayerVariables.hoveredSlot.heldItem
			if item != null:
				equip_item(item)
		clicki = 0


func _process(delta: float) -> void:
	if !clickHeld:
		return
	
	var mousePosition: Vector2 = get_global_mouse_position()
	if currentSlotIcon != null:
		currentSlotIcon.global_position = Vector2(mousePosition.x - (currentSlotIcon.size.x/2), mousePosition.y - (currentSlotIcon.size.y/2))


func open_inventory():
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)
	GlobalPlayerVariables.lookingEnabled = false
	
	self.show()
	inventoryOpen = true
	
	clear_equip()


func close_inventory():
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_CAPTURED)
	GlobalPlayerVariables.lookingEnabled = true
	
	self.hide()
	inventoryOpen = false


func on_pickup_item(item: Item):
	for i in slots.size():
		if slots[i].heldItem == null:
			slots[i].heldItem = item
			
			slots[i].slotIcon.texture = item.inventorySprite
			slots[i].slotText.text = item.inventoryName
			break


func on_drop_item(slot: InventorySlot):
	var randomPos = Vector3(randf_range(-0.25, 0.25), 1, randf_range(-0.25, 0.25))
	var randomRotation = randi_range(0, 360)
	
	slot.heldItem.global_position = GlobalPlayerVariables.playerPosition + randomPos
	slot.heldItem.global_rotation.y = randomRotation
	slot.heldItem.reparent(get_tree().root)
	slot.heldItem.freeze = false
	
	slot.heldItem = null
	slot.slotIcon.texture = null
	slot.slotText.text = ""


func swap_item(prevSlot: InventorySlot, newSlot: InventorySlot):
	var temporaryItem: Item = null
	
	if newSlot.heldItem == null:
		newSlot.heldItem = prevSlot.heldItem
		newSlot.slotIcon.texture = prevSlot.heldItem.inventorySprite
		newSlot.slotText.text = prevSlot.slotText.text
		
		prevSlot.heldItem = null
		prevSlot.slotIcon.texture = null
		prevSlot.slotText.text = ""
	else:
		temporaryItem = newSlot.heldItem
		
		newSlot.heldItem = prevSlot.heldItem
		newSlot.slotIcon.texture = prevSlot.heldItem.inventorySprite
		newSlot.slotText.text = prevSlot.slotText.text
		
		prevSlot.heldItem = temporaryItem
		prevSlot.slotIcon.texture = temporaryItem.inventorySprite
		prevSlot.slotText.text = temporaryItem.inventoryName


func equip_item(item: Item):
	equippedItemFrame.show()
	
	equippedItem = item
	equippedItemIcon.texture = item.inventorySprite
	
	close_inventory()
	pass


func clear_equip():
	equippedItemFrame.hide()
	equippedItem = null


func _on_slots_mouse_entered() -> void:
	overDropArea = false
func _on_slots_mouse_exited() -> void:
	overDropArea = true
