extends Control


func _ready() -> void:
	SignalBus.connect("win_game", show_screen)


func show_screen(time: String):
	$Time.text = "Time: %s" % time
	self.show()
