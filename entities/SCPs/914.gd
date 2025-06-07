extends StaticBody3D

var knobSetting: int

@export var veryFineDict: Dictionary[String, PackedScene]
@export var fineDict: Dictionary[String, PackedScene]
@export var onetooneDict: Dictionary[String, PackedScene]
@export var coarseDict: Dictionary[String, PackedScene]
@export var roughDict: Dictionary[String, PackedScene]

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
	if event is InputEventMouseMotion and Input.is_action_pressed("interact") and fakeNearKnob and !refining:
		knob.rotate_z(event.relative.x * 0.005) 
	if event is InputEventMouseMotion and Input.is_action_pressed("interact") and fakeNearKey and !refining:
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
		if fakeNearKey and !refining:
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
		
		match knobSetting:
			0:
				if roughDict.has(inputItem.itemName):
					outputItem = roughDict[inputItem.itemName]
			1:
				if coarseDict.has(inputItem.itemName):
					outputItem = coarseDict[inputItem.itemName]
			2:
				if onetooneDict.has(inputItem.itemName):
					outputItem = onetooneDict[inputItem.itemName]
			3:
				if fineDict.has(inputItem.itemName):
					outputItem = fineDict[inputItem.itemName]
			4:
				if veryFineDict.has(inputItem.itemName):
					outputItem = veryFineDict[inputItem.itemName]
		
		print(outputItem)
		if outputItem != null:
			var spawnedItem = outputItem.instantiate()
			get_tree().root.add_child(spawnedItem)
			spawnedItem.global_position = outputPoint.global_position
			inputItem.queue_free()
			
		else:
			inputItem.global_position = outputPoint.global_position
	
	doorL.toggle_door()
	doorR.toggle_door()
	
	refining = false


func show_interaction_sprite(onWhat: Node3D):
	if !refining:
		interactionScript.interactionSprite.show()
		interactionScript.nearestInteractable = onWhat


func _on_knob_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		show_interaction_sprite(knob)
		nearControls = true
func _on_knob_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		interactionScript.interactionSprite.hide()
		nearControls = false


func _on_input_body_entered(body: Item) -> void:
	itemsInInput.append(body)
func _on_input_body_exited(body: Item) -> void:
	itemsInInput.erase(body)


func _on_knob_area_area_entered(area: Area3D) -> void:
	if area.is_in_group("grabbypoint"):
		nearKnob = true
		show_interaction_sprite(knob)
func _on_knob_area_area_exited(area: Area3D) -> void:
	if area.is_in_group("grabbypoint"):
		nearKnob = false
		interactionScript.interactionSprite.hide()


func _on_key_area_area_entered(area: Area3D) -> void:
	if area.is_in_group("grabbypoint"): 
		nearKey = true
		show_interaction_sprite(key)
func _on_key_area_area_exited(area: Area3D) -> void:
	if area.is_in_group("grabbypoint"):
		nearKey = false
		interactionScript.interactionSprite.hide()
