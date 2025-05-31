extends StaticBody3D

@export var roughDict: Dictionary[Item, PackedScene]
@export var coarseDict: Dictionary
@export var onetooneDict: Dictionary
@export var fineDict: Dictionary
@export var veryFineDict: Dictionary

@export var knob: MeshInstance3D

var interactionScript: Interaction
var nearKnob: bool = false

var itemsInInput: Array[Item]

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.is_action_pressed("interact"):
		knob.rotate_z(event.relative.x * 0.005) 


func _ready() -> void:
	interactionScript = GlobalPlayerVariables.interactionScript


func _process(delta: float) -> void:
	var angle = knob.rotation_degrees.z
	if !Input.is_action_pressed("interact") and nearKnob:
		if angle > 67:
			knob.rotation_degrees.z = lerp(knob.rotation_degrees.z, 90.0, 0.25)
		elif angle < 67 and !angle < 23:
			knob.rotation_degrees.z = lerp(knob.rotation_degrees.z, 45.0, 0.25)
		elif angle < 23 and !angle < -23:
			knob.rotation_degrees.z = lerp(knob.rotation_degrees.z, 0.0, 0.25)
		elif angle < -23 and !angle < -67:
			knob.rotation_degrees.z = lerp(knob.rotation_degrees.z, -45.0, 0.25)
		elif angle < -67:
			knob.rotation_degrees.z = lerp(knob.rotation_degrees.z, -90.0, 0.25)
	
	knob.rotation.z = clamp(knob.rotation.z, deg_to_rad(-90), deg_to_rad(90))


func _on_knob_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		interactionScript.interactionSprite.show()
		interactionScript.nearestInteractable = knob
		nearKnob = true
func _on_knob_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		nearKnob = false
		interactionScript.interactionSprite.hide()
		interactionScript.nearestInteractable = knob



func _on_input_body_entered(body: Node3D) -> void:
	itemsInInput.append(body)
	print(itemsInInput)
func _on_input_body_exited(body: Node3D) -> void:
	itemsInInput.erase(body)
	print(itemsInInput)
