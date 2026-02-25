extends StaticBody3D

@export var knobSetting: int: 
	set(val):
		if val != knobSetting:
			$KnobTurn.play()
		
		knobSetting = val

@export var veryFineDict: Dictionary[String, String]
@export var fineDict: Dictionary[String, String]
@export var onetooneDict: Dictionary[String, String]
@export var coarseDict: Dictionary[String, String]
@export var roughDict: Dictionary[String, String]

@export var doorL: Door
@export var doorR: Door

@export var refiningAudioPlayer: AudioStreamPlayer3D
@export var knob: MeshInstance3D
@export var key: MeshInstance3D
@export var turningKeyUI: TextureRect

var interactionScript: Interaction
var nearControls: bool = false
var nearKnob: bool = false
var nearKey: bool = false

var clickingOnKnob: bool = false
var clickingOnKey: bool = false
var keyJuice: float = 0
var refining: bool = false

var itemsInInput: Array[Item]
@export var outputPoint: Node3D

var relativeMouseMotion := Vector2.ZERO
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		relativeMouseMotion = event.relative
	
	if event.is_action_pressed("interact"):
		keyJuice = 0
		
		clickingOnKnob = nearKnob
		clickingOnKey = nearKey
		
		if clickingOnKnob:
			show_interaction_sprite(knob)
		
		if clickingOnKey and !refining:
			turningKeyUI.show()
			hide_interaction_sprite()
	
	if event.is_action_released("interact"):
		keyJuice = 0
		
		clickingOnKnob = false
		clickingOnKey = false
		
		hide_interaction_sprite()
		turningKeyUI.hide()



func _ready() -> void:
	interactionScript = GlobalPlayerVariables.interactionScript
	
	doorL.open.rpc()
	doorR.open.rpc()


func _process(delta: float) -> void:
	if Input.is_action_pressed("interact"):
		if clickingOnKnob and !refining:
			knob.rotate_z(relativeMouseMotion.x * 0.005) 
		
		if clickingOnKey and !refining:
			keyJuice += abs(relativeMouseMotion.x)
	
	if keyJuice > 700 and clickingOnKey and !refining:
		clickingOnKey = false
		turningKeyUI.hide()
		activate.rpc()
	
	var angle = knob.rotation_degrees.z
	
	if angle > 67:
		knobSetting = 4
	elif angle < 67 and !angle < 23:
		knobSetting = 3
	elif angle < 23 and !angle < -23:
		knobSetting = 2
	elif angle < -23 and !angle < -67:
		knobSetting = 1
	elif angle < -67:
		knobSetting = 0
	
	if !Input.is_action_pressed("interact") and nearControls:
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
	update_values.rpc(knobSetting, knob.rotation_degrees.z)


@rpc("reliable", "any_peer", "call_local")
func update_values(setting: int, rotation: float):
	knobSetting = setting
	knob.rotation_degrees.z = rotation


@rpc("reliable", "any_peer", "call_local")
func activate():
	refining = true
	
	refiningAudioPlayer.play()
	await get_tree().create_timer(0.5).timeout
	doorL.close()
	doorR.close()
	await get_tree().create_timer(13.5).timeout
	
	process_items()
	
	doorL.open()
	doorR.open()
	
	refining = false


func process_items():
	if !multiplayer.is_server():
		return
	
	for inputItem in itemsInInput:
		var outputItemName: String = ""
		
		match knobSetting:
			0:
				if roughDict.has(inputItem.itemName):
					outputItemName = roughDict.get(inputItem.itemName)
			1:
				if coarseDict.has(inputItem.itemName):
					outputItemName = coarseDict.get(inputItem.itemName)
			2:
				if onetooneDict.has(inputItem.itemName):
					outputItemName = onetooneDict.get(inputItem.itemName)
			3:
				if fineDict.has(inputItem.itemName):
					outputItemName = fineDict.get(inputItem.itemName)
			4:
				if veryFineDict.has(inputItem.itemName):
					outputItemName = veryFineDict.get(inputItem.itemName)
		
		print(outputItemName)
		if outputItemName == null or outputItemName == "":
			ItemManager.update_item_position.rpc(inputItem.itemID, outputPoint.global_position)
			continue
		
		Commands.make_item.rpc(outputItemName, outputPoint.global_position)
		print("914 Input Item: %s -- Knob Setting: %s" % [inputItem, knobSetting])
		print("914 Output Item: %s" % outputItemName)
		
		inputItem.queue_free()


func _on_input_body_entered(body: Node3D) -> void:
	if body.is_in_group("item"):
		itemsInInput.append(body)
func _on_input_body_exited(body: Node3D) -> void:
	if body.is_in_group("item"):
		itemsInInput.erase(body)


func show_interaction_sprite(onWhat: Node3D):
	if !refining:
		interactionScript.show_sprite()
		interactionScript.nearestInteractable = onWhat

func hide_interaction_sprite():
	if !clickingOnKnob and !nearKey and !nearKnob:
		interactionScript.hide_sprite()
		interactionScript.nearestInteractable = null


func _on_knob_area_area_entered(area: Area3D) -> void:
	if area.is_in_group("grabbypoint"):
		nearKnob = true
		show_interaction_sprite(knob)
func _on_knob_area_area_exited(area: Area3D) -> void:
	if area.is_in_group("grabbypoint"):
		nearKnob = false
		hide_interaction_sprite()


func _on_key_area_area_entered(area: Area3D) -> void:
	if area.is_in_group("grabbypoint"): 
		nearKey = true
		show_interaction_sprite(key)
func _on_key_area_area_exited(area: Area3D) -> void:
	if area.is_in_group("grabbypoint"):
		nearKey = false
		hide_interaction_sprite()
