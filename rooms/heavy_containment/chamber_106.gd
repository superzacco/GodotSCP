extends Room

@export var chamberAnimPlayer: AnimationPlayer
@export var electromagnetLever: Lever
@export var summonPositionMarker: Marker3D

var chamberRaised: bool = false
var femurUsed := false
var femurBreakerSequenceActive: bool = false
var scp106: SCP106 = null

func _ready() -> void:
	chamberAnimPlayer.play("idle")


@rpc("any_peer", "call_local", "reliable")
func raise_106_chamber():
	electromagnetLever.disableInteraction = true
	chamberAnimPlayer.play("rise")
	await chamberAnimPlayer.animation_finished
	chamberAnimPlayer.play("float")
	
	chamberRaised = true
	if femurBreakerSequenceActive: scp106.captured = true
	
	electromagnetLever.disableInteraction = false


@rpc("any_peer", "call_local", "reliable")
func lower_106_chamber():
	electromagnetLever.disableInteraction = true
	chamberAnimPlayer.play_backwards("rise")
	await chamberAnimPlayer.animation_finished
	chamberAnimPlayer.play("idle")
	
	chamberRaised = false
	if femurBreakerSequenceActive: release_106()
	
	electromagnetLever.disableInteraction = false


@rpc("any_peer", "call_local", "reliable")
func break_the_femur():
	if femurUsed: return
	femurUsed = true
	
	scp106 = GlobalPlayerVariables.facilityManager.scp106
	await get_tree().create_timer(5.0).timeout
	
	femurBreakerSequenceActive = true
	scp106.rise(summonPositionMarker.global_position)
	scp106.animationSpeed = 0.40
	scp106.modelAnimations.animation_finished.connect(to_contain_or_not_to_contain_that_is_the_question)


@rpc("any_peer", "call_local", "reliable")
func release_106():
	scp106.begin_chase(summonPositionMarker.global_position)
	scp106.captured = false
	femurBreakerSequenceActive = false


func to_contain_or_not_to_contain_that_is_the_question():
	if chamberRaised: scp106.on_106_contained()
	else: release_106()


func _on_electromagnet_lever_lever_activated() -> void:
	raise_106_chamber.rpc()

func _on_electromagnet_lever_lever_deactivated() -> void:
	lower_106_chamber.rpc()


func _on_femur_breaker_button_activated() -> void:
	break_the_femur.rpc()
