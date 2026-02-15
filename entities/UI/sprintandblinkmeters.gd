extends Control

@export var blinkMeter: TextureProgressBar
@export var sprintMeter: TextureProgressBar
@export var blinkIcon: TextureRect

@export var normalBlinkIcon: Texture2D
@export var quickenedBlinkIcon: Texture2D


@onready var player: Player = GameManager.get_player_by_id(self.get_multiplayer_authority())


func _physics_process(delta: float) -> void:
	update_blink_meter()


func update_blink_meter():
	if player == null:
		return
	
	blinkMeter.value = snapped(player.blinkinator.blinkJuice, 5)
	sprintMeter.value = snapped(player.sprintJuice, 5)
	
	if player.blinkQuickened and !player.wearingGasMask:
		blinkIcon.texture = quickenedBlinkIcon
	else:
		blinkIcon.texture = normalBlinkIcon
