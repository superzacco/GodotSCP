extends Control

@export var zoomRate: float

@export var paper: TextureRect
@export var point: Control

var clicking: bool = false
var hovering: bool = false
var delay: bool = true

var defaultSize = 1.0
var maxSize = 2.2

func _ready() -> void:
	SignalBus.connect("equip_paper", equip_paper)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory") and self.visible:
		hide_paper()
	
	if event.is_action("mwheelup") and self.visible:
		if paper.scale.x >= maxSize:
			return
		
		paper.scale.x += paper.scale.x * zoomRate
		paper.scale.y += paper.scale.y * zoomRate
	
	if event.is_action("mwheeldown") and self.visible:
		if paper.scale.x <= defaultSize:
			return
		
		paper.scale.x -= paper.scale.x * zoomRate
		paper.scale.y -= paper.scale.y * zoomRate
	
	if event.is_action_pressed("interact"):
		clicking = true
	if event.is_action_released("interact"):
		clicking = false
	
	if event is InputEventMouseMotion and can_move():
		paper.position += Vector2(event.relative.x, event.relative.y) * 1.2


func can_move() -> bool:
	if clicking and hovering and self.visible and !delay:
		return true
	return false


func hide_paper():
	delay = true
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_CAPTURED)
	GlobalPlayerVariables.lookingEnabled = true
	
	self.hide()
	paper.texture = null
	
	if paper.get_children().size() > 0:
		for child in paper.get_children():
			child.queue_free()
	
	await get_tree().process_frame
	GlobalPlayerVariables.inventory.close_inventory()
	GlobalPlayerVariables.inventory.clear_equip()
	GlobalPlayerVariables.immutableMenuOpen = false


func equip_paper(document: Texture2D, otherDocument: PackedScene = null):
	GlobalPlayerVariables.immutableMenuOpen = true
	GlobalPlayerVariables.inventory.close_inventory()
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)
	GlobalPlayerVariables.lookingEnabled = false
	
	self.show()
	
	if document:
		show_paper_texture(document)
	if otherDocument:
		show_other_document(otherDocument)
	
	await get_tree().create_timer(0.2).timeout
	delay = false



func show_paper_texture(image: Texture2D):
	paper.texture = image
	paper.set_position(Vector2.ZERO - (paper.size/2))
	paper.scale = Vector2(defaultSize, defaultSize)


func show_other_document(document: PackedScene):
	var doc: Control = document.instantiate()
	
	paper.set_size(doc.size)
	paper.add_child(doc)
	doc.set_position(Vector2.ZERO)
	doc.z_index = 12
	


func _on_paper_mouse_entered() -> void:
	hovering = true

func _on_paper_mouse_exited() -> void:
	hovering = false
