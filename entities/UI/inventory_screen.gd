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
	SignalBus.connect("toggle_gas_mask", close_inventory)
	ItemManager.connect("update_slot_ui", clear_slot_ui)
	
	for i in slotsNode.get_children().size():
		slots.append(slotsNode.get_child(i))
	
	if is_multiplayer_authority():
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
	
	if Input.is_action_just_released("quit") and inventoryOpen:
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
			ItemManager.request_item_drop.rpc(heldItem.name, hoveredSlotIdx)
		
		if GlobalPlayerVariables.hoveredSlot != null and heldItem != null:
			swap_item(currentSlot, GlobalPlayerVariables.hoveredSlot)
		
		clickHeld = false
		currentSlot = null
		currentSlotIcon = null
		heldItem = null
	
	if event.is_action_pressed("interact") and inventoryOpen:
		clicki += 1
		if clicki >= 2 and GlobalPlayerVariables.hoveredSlot != null:
			var item = GlobalPlayerVariables.hoveredSlot.heldItem
			if item != null:
				equip_item(item)
		
		await  get_tree().create_timer(0.25).timeout
		clicki = 0


func _process(delta: float) -> void:
	if !clickHeld or !is_multiplayer_authority():
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



@rpc("reliable", "call_local")
func clear_slot_ui(slotIdx: int):
	if slotIdx < 0 or slotIdx >= slots.size():
		return
	
	var slot: InventorySlot = slots[slotIdx]
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
	if item.equippable == true:
		item.functionItem.equip()
		if item.equipped:
			item.equipped = false
		else:
			item.equipped = true
		close_inventory()
		return
	
	equippedItemFrame.show()
	
	equippedItem = item
	equippedItemIcon.texture = item.inventorySprite
	
	close_inventory()


func clear_equip():
	equippedItemFrame.hide()
	equippedItem = null


func _on_slots_mouse_entered() -> void:
	overDropArea = false
func _on_slots_mouse_exited() -> void:
	overDropArea = true
