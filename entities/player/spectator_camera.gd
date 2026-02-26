extends Node3D
class_name SpectatorCamera

@export var associatedUI: Control
@export var camera: Camera3D
@export var horizontalPivot: Node3D
@export var verticalPivot: Node3D

var specManager: SpectatorManager
var spectatedThing: Node3D
var specIdx: int


func _ready() -> void:
	camera.current = is_multiplayer_authority()
	
	specManager = GlobalPlayerVariables.spectatorManager
	forward_spec()


func _input(event: InputEvent) -> void:
	if !is_multiplayer_authority() or GlobalPlayerVariables.consoleOpen or GlobalPlayerVariables.immutableMenuOpen:
		return
	
	if event is InputEventMouseMotion:
		horizontalPivot.rotate_y(deg_to_rad(-event.relative.x * GlobalPlayerVariables.sensitivity * 0.05))
		verticalPivot.rotate_x(deg_to_rad(-event.relative.y * GlobalPlayerVariables.sensitivity * 0.05))
		verticalPivot.rotation.x = clamp(verticalPivot.rotation.x, deg_to_rad(-89), deg_to_rad(89))
	
	if event.is_action_pressed("interact"):
		forward_spec()
	
	if event.is_action_pressed("rightclick"):
		backward_spec()


func _process(delta: float) -> void:
	if !is_multiplayer_authority() or !specManager.spectatableThings.size() > 0:
		return
	
	if spectatedThing == null:
		forward_spec()
	else:
		self.global_position = lerp(self.global_position, spectatedThing.global_position, 0.25)


func forward_spec():
	specManager.refresh_spectatable_objects()
	
	specIdx += 1
	if specIdx > specManager.spectatableThings.size()-1:
		specIdx = 0
	
	switch_spectating()

func backward_spec():
	specManager.refresh_spectatable_objects()
	
	specIdx -= 1
	if specIdx < 0:
		specIdx = specManager.spectatableThings.size()-1
	
	switch_spectating()


func switch_spectating():
	spectatedThing = specManager.spectatableThings[specIdx]
	associatedUI.set_label("Spectating: %s" % spectatedThing.name)
