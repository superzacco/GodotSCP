extends Control

@export var zoomRate: float

@export var paper: TextureRect
@export var point: Control

var clicking: bool = false
var hovering: bool = false
var delay: bool = true

var defaultSize = 1.0
var maxSize = 2.2

var startPos := Vector2.ZERO

func _ready() -> void:
	startPos = paper.position
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
		paper.position += Vector2(event.relative.x, event.relative.y)


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
	
	await get_tree().process_frame
	GlobalPlayerVariables.inventory.close_inventory()
	GlobalPlayerVariables.immutableMenuOpen = false


func equip_paper(image: Texture2D):
	GlobalPlayerVariables.immutableMenuOpen = true
	GlobalPlayerVariables.inventory.close_inventory()
	
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)
	GlobalPlayerVariables.lookingEnabled = false
	
	paper.set_position(startPos)
	paper.scale = Vector2(defaultSize, defaultSize)
	
	self.show()
	paper.texture = image
	
	await get_tree().create_timer(0.2).timeout
	delay = false


func _on_paper_mouse_entered() -> void:
	hovering = true

func _on_paper_mouse_exited() -> void:
	hovering = false
