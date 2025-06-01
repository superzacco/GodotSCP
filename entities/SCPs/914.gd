extends StaticBody3D

var knobSetting: int

@export var doorL: StaticBody3D
@export var doorR: StaticBody3D
@export var refiningAudioPlayer: AudioStreamPlayer3D

@export var knob: MeshInstance3D
@export var key: MeshInstance3D
@export var turningKnobUI: TextureRect

var interactionScript: Interaction
var nearControls: bool = false
var nearKnob: bool = false
var nearKey: bool = false

var fakeNearKnob: bool = false
var fakeNearKey: bool = false
var keyJuice: float = 0
var refining: bool = false

var itemsInInput: Array[Item]
@export var outputPoint: Node3D

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.is_action_pressed("interact") and fakeNearKnob:
		knob.rotate_z(event.relative.x * 0.005) 
	if event is InputEventMouseMotion and Input.is_action_pressed("interact") and fakeNearKey:
		keyJuice += abs(event.relative.x)


func _ready() -> void:
	interactionScript = GlobalPlayerVariables.interactionScript
	doorL.doorOpen = true
	doorR.doorOpen = true


func _process(delta: float) -> void:
	if keyJuice > 500 and fakeNearKey and !refining:
		fakeNearKey = false
		turningKnobUI.hide()
		activate()
	
	if Input.is_action_just_pressed("interact"):
		keyJuice = 0
		fakeNearKnob = nearKnob
		fakeNearKey = nearKey
		if fakeNearKey:
			turningKnobUI.show()
		interactionScript.interactionSprite.hide()
	if Input.is_action_just_released("interact"):
		keyJuice = 0
		turningKnobUI.hide()
	
	var angle = knob.rotation_degrees.z
	if !Input.is_action_pressed("interact") and nearControls:
		if angle > 67:
			knob.rotation_degrees.z = lerp(knob.rotation_degrees.z, 90.0, 0.25)
			knobSetting = 4
		elif angle < 67 and !angle < 23:
			knob.rotation_degrees.z = lerp(knob.rotation_degrees.z, 45.0, 0.25)
			knobSetting = 3
		elif angle < 23 and !angle < -23:
			knob.rotation_degrees.z = lerp(knob.rotation_degrees.z, 0.0, 0.25)
			knobSetting = 2
		elif angle < -23 and !angle < -67:
			knob.rotation_degrees.z = lerp(knob.rotation_degrees.z, -45.0, 0.25)
			knobSetting = 1
		elif angle < -67:
			knob.rotation_degrees.z = lerp(knob.rotation_degrees.z, -90.0, 0.25)
			knobSetting = 0
	
	knob.rotation.z = clamp(knob.rotation.z, deg_to_rad(-90), deg_to_rad(90))


func activate():
	refining = true
	
	refiningAudioPlayer.play()
	await get_tree().create_timer(0.5).timeout
	doorL.toggle_door()
	doorR.toggle_door()
	await get_tree().create_timer(15).timeout
	
	for inputItem in itemsInInput:
		var outputItem: PackedScene = null
		var nonAffectedItem = null
		
		match knobSetting:
			0:
				if inputItem.roughItem == null:
					nonAffectedItem = inputItem
				else:
					outputItem = inputItem.roughItem
			1:
				if inputItem.coarseItem == null:
					nonAffectedItem = inputItem
				else:
					outputItem = inputItem.coarseItem
			2:
				if inputItem.onetooneItem == null:
					nonAffectedItem = inputItem
				else:
					outputItem = inputItem.onetooneItem
			3:
				if inputItem.fineItem == null:
					nonAffectedItem = inputItem
				else:
					outputItem = inputItem.fineItem
			4:
				if inputItem.veryFineItem == null:
					nonAffectedItem = inputItem
				else:
					outputItem = inputItem.veryFineItem
		
		inputItem.queue_free()
		if outputItem != null:
			var spawnedItem = outputItem.instantiate()
			get_tree().root.add_child(spawnedItem)
			spawnedItem.global_position = outputPoint.global_position
		else:
			push_error("Output item was null")
		
		if nonAffectedItem != null:
			nonAffectedItem.global_position = outputPoint.global_position
	
	doorL.toggle_door()
	doorR.toggle_door()
	
	refining = false


func _on_knob_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		interactionScript.interactionSprite.show()
		interactionScript.nearestInteractable = knob
		nearControls = true
func _on_knob_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		interactionScript.interactionSprite.hide()
		interactionScript.nearestInteractable = knob
		nearControls = false


func _on_input_body_entered(body: Node3D) -> void:
	itemsInInput.append(body)
	print(itemsInInput)
func _on_input_body_exited(body: Node3D) -> void:
	itemsInInput.erase(body)
	print(itemsInInput)


func _on_knob_area_area_entered(area: Area3D) -> void:
	if area.is_in_group("grabbypoint"):
		nearKnob = true
		print("nearknob equals " + str(nearKnob))
		interactionScript.interactionSprite.show()
		interactionScript.nearestInteractable = knob
func _on_knob_area_area_exited(area: Area3D) -> void:
	if area.is_in_group("grabbypoint"):
		nearKnob = false
		print("nearknob equals " + str(nearKnob))
		interactionScript.interactionSprite.hide()
		interactionScript.nearestInteractable = knob


func _on_key_area_area_entered(area: Area3D) -> void:
	if area.is_in_group("grabbypoint"):
		nearKey = true
		interactionScript.interactionSprite.show()
		interactionScript.nearestInteractable = key
		print("nearkey equals " + str(nearKey))
func _on_key_area_area_exited(area: Area3D) -> void:
	if area.is_in_group("grabbypoint"):
		nearKey = false
		print("nearkey equals " + str(nearKey))
		interactionScript.interactionSprite.hide()
		interactionScript.nearestInteractable = key
