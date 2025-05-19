extends TextureRect
class_name InventorySlot


@export var outline: TextureRect
@export var slotIcon: TextureRect
@export var slotText: Label

var heldItem: Item


func _on_mouse_entered() -> void:
	outline.show()
	slotText.show()
	GlobalPlayerVariables.hoveredSlot = self


func _on_mouse_exited() -> void:
	outline.hide()
	slotText.hide()
	GlobalPlayerVariables.hoveredSlot = null
