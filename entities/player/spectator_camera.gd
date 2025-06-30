extends Node3D
class_name SpectatorCamera

@export var associatedUI: Control
@export var camera: Camera3D
@export var horizontalPivot: Node3D
@export var verticalPivot: Node3D

var specManager: SpectatorManager
var specIdx: int


func _ready() -> void:
	camera.current = is_multiplayer_authority()
	
	specManager = GlobalPlayerVariables.spectatorManager
	switch_spectating()


func _input(event: InputEvent) -> void:
	if !is_multiplayer_authority():
		return
	
	if event is InputEventMouseMotion:
		horizontalPivot.rotate_y(deg_to_rad(-event.relative.x * GlobalPlayerVariables.sensitivity * 0.05))
		verticalPivot.rotate_x(deg_to_rad(-event.relative.y * GlobalPlayerVariables.sensitivity * 0.05))
		verticalPivot.rotation.x = clamp(verticalPivot.rotation.x, deg_to_rad(-89), deg_to_rad(89))
	
	if event.is_action_pressed("interact"):
		switch_spectating()


func _process(delta: float) -> void:
	if specManager.spectatableThings.size() > 0:
		if specManager.spectatableThings[specIdx] == null:
			specManager.get_spectatable_objects()
			switch_spectating()
		else:
			self.global_position = lerp(self.global_position, specManager.spectatableThings[specIdx].global_position, 0.1)

func switch_spectating():
	specManager.get_spectatable_objects()
	
	if specIdx == specManager.spectatableThings.size()-1:
		specIdx = 0
	
	associatedUI.set_label("Spectating: %s" % specManager.spectatableThings[specIdx].name)
