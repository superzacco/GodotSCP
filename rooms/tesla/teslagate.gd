extends Sprite3D

var thingsInKillBox: Array
var thingsInDetectionArea: Array

var coolingDown: bool


func _ready() -> void:
	$TeslaIdle.play()
	self.hide()
	pass


func _on_tesla_trigger_box_body_entered(body: Node3D) -> void:
	if body.is_in_group("teslashockable"):
		thingsInDetectionArea.append(body)
		if !coolingDown:
			charge()


func _on_tesla_trigger_box_body_exited(body: Node3D) -> void:
	if body.is_in_group("teslashockable"):
		thingsInDetectionArea.erase(body)


func _on_tesla_kill_box_body_entered(body: Node3D) -> void:
	if body.is_in_group("teslashockable"):
		thingsInKillBox.append(body)


func _on_tesla_kill_box_body_exited(body: Node3D) -> void:
	if body.is_in_group("teslashockable"):
		thingsInKillBox.erase(body)


func charge():
	coolingDown = true
	
	$TeslaCharge.play()
	await get_tree().create_timer(0.5).timeout
	shock()
	
	await get_tree().create_timer(0.5).timeout
	
	$TeslaIdle.play()
	await get_tree().create_timer(1.5).timeout
	reset()


func shock():
	$TeslaFire.play()
	$TeslaIdle.stop()
	$AnimationPlayer.play("teslafire")
	
	if !multiplayer.is_server():
		return
	
	if thingsInKillBox.size() > 0:
		for player: Player in thingsInKillBox:
			print("Shocking Player: %s in Tesla Gate!" % player.get_multiplayer_authority())
			player.take_damage(999)


func reset():
	coolingDown = false
	
	if thingsInDetectionArea.size() > 0:
		charge()
