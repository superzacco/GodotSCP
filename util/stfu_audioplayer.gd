extends AudioStreamPlayer3D


func _ready() -> void:
	SignalBus.shut_up_sounds.connect(shut_up)
	SignalBus.come_back_sounds.connect(come_back)

func shut_up():
	self.stop()

func come_back():
	self.play()
