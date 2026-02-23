extends StaticBody3D

@export var knobSetting: int: 
	set(val):
		if val != knobSetting:
			$KnobTurn.play()
		
		knobSetting = val

@export var veryFineDict: Dictionary[String, PackedScene]
@export var fineDict: Dictionary[String, PackedScene]
@export var onetooneDict: Dictionary[String, PackedScene]
@export var coarseDict: Dictionary[String, PackedScene]
@export var roughDict: Dictionary[String, PackedScene]

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
		
		if clickingOnKey and !refining:
			turningKeyUI.show()
			interactionScript.interactionSprite.hide()
		
		clickingOnKnob = nearKnob
		clickingOnKey = nearKey
	
	if event.is_action_released("interact"):
		turningKeyUI.hide()
		keyJuice = 0



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
	
	if keyJuice > 500 and clickingOnKey and !refining:
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
	
	for inputItem in itemsInInput:
		var outputItem: PackedScene = null
		
		match knobSetting:
			0:
				if roughDict.has(inputItem.itemName):
					outputItem = roughDict.get(inputItem.itemName)
			1:
				if coarseDict.has(inputItem.itemName):
					outputItem = coarseDict.get(inputItem.itemName)
			2:
				if onetooneDict.has(inputItem.itemName):
					outputItem = onetooneDict.get(inputItem.itemName)
			3:
				if fineDict.has(inputItem.itemName):
					outputItem = fineDict.get(inputItem.itemName)
			4:
				if veryFineDict.has(inputItem.itemName):
					outputItem = veryFineDict.get(inputItem.itemName)
		
		print("914 Output Item: %s" % outputItem)
		print("914 Input Item: %s -- Knob Setting: %s" % [inputItem, knobSetting])
		if outputItem != null: 
			var spawnedItem: Item = outputItem.instantiate()
			self.add_child(spawnedItem)
			spawnedItem.setup_item()
			spawnedItem.global_position = outputPoint.global_position
			inputItem.queue_free()
			
		else:
			inputItem.global_position = outputPoint.global_position
	
	doorL.open()
	doorR.open()
	
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


func _on_input_body_entered(body: Node3D) -> void:
	if body.is_in_group("item"):
		var item: Item = body
		item.get_id()
		
		itemsInInput.append(body)
func _on_input_body_exited(body: Node3D) -> void:
	if body.is_in_group("item"):
		var item: Item = body
		
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
