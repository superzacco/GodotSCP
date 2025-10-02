extends Door

func open():
	$celldoor/AnimationPlayer.play("open")
	$Open.play()
