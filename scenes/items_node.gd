extends Node3D

func _ready() -> void:
	SignalBus.reparent_item.connect(reparent_item)

func reparent_item(item: Item):
	self.add_child(item)
	
