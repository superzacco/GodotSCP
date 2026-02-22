extends Door

func _ready() -> void:
	SignalBus.connect("level_generation_finished", open)

func open():
	$celldoor/AnimationPlayer.play("open")
	$Open.play()
