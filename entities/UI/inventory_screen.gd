extends Control
class_name Inventory

@export var equippedItemFrame: TextureRect
var equippedItemIcon: TextureRect 

@export var slotsNode: GridContainer
var slots: Array[InventorySlot]

var inventoryOpen: bool = false
var clickHeld: bool = false
var overDropArea: bool = false

var equippedMask: Item

var equippedItem: Item
var heldItem: Item
var hoveredSlotIdx: int

var currentSlot: InventorySlot
var currentSlotIcon: TextureRect
var iconOriginPoint: Vector2

func _ready() -> void:
	if !is_multiplayer_authority():
		return
	
	GlobalPlayerVariables.inventory = self
	
	SignalBus.connect("toggle_gas_mask_overlay", close_inventory)
	SignalBus.connect("hide_inventory", close_inventory)
	
	for i in slotsNode.get_children().size():
		slots.append(slotsNode.get_child(i))
	
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
			drop_item()
		
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
				if !item.equipped: equip_item(item); return
				
				if item.equipped:
					if item.itemType == Item.ItemType.type_mask:
						clear_worn_mask()
					else:
						clear_equip()
		
		await  get_tree().create_timer(0.25).timeout
		clicki = 0


func _process(delta: float) -> void:
	if  !is_multiplayer_authority() or !clickHeld:
		return
	
	var mousePosition: Vector2 = get_global_mouse_position()
	if currentSlotIcon != null:
		currentSlotIcon.global_position = Vector2(mousePosition.x - (currentSlotIcon.size.x/2), mousePosition.y - (currentSlotIcon.size.y/2))


func open_inventory():
	if inventoryOpen:
		return
	
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)
	GlobalPlayerVariables.lookingEnabled = false
	
	self.show()
	inventoryOpen = true
	
	clear_equip()


func close_inventory():
	if !inventoryOpen:
		return
	
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


func drop_item():
	ItemManager.request_item_drop.rpc(heldItem.itemID)
	clear_slot_ui(hoveredSlotIdx)
	
	var itemTypes := Item.ItemType
	match heldItem.itemType:
		itemTypes.type_mask:
			clear_worn_mask()
		itemTypes.type_paper:
			clear_equip()
		itemTypes.type_card:
			clear_equip()


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
	if !item.equippable:
		return
	
	item.equipped = true
	
	var itemTypes := Item.ItemType
	match item.itemType:
		
		itemTypes.type_card:
			equippedItem = item
			
			equippedItemFrame.show()
			equippedItemIcon.texture = item.inventorySprite
		
		itemTypes.type_mask:
			equippedMask = item
			item.functionItem.equip()
		
		itemTypes.type_paper:
			equippedItem = item
			item.functionItem.equip()
		
		_:
			item.functionItem.equip()
			item.equipped = false
	
	close_inventory()


func clear_equip():
	equippedItemFrame.hide()
	
	if equippedItem != null:
		equippedItem.equipped = false
		equippedItem = null


func clear_worn_mask():
	if equippedMask == null:
		return
	
	equippedMask.functionItem.equip()
	
	equippedMask.equipped = false
	equippedMask = null


func return_empty_slots() -> int:
	var i := 0
	for slot: InventorySlot in slots:
		if slot.heldItem == null: 
			i += 1
	
	return i


func _on_slots_mouse_entered() -> void:
	overDropArea = false
func _on_slots_mouse_exited() -> void:
	overDropArea = true
