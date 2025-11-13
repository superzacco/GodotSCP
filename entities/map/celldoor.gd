extends Door

func _ready() -> void:
	super()
	SignalBus.connect("level_generation_finished", open)

func open():
	$celldoor/AnimationPlayer.play("open")
	$Open.play()
