extends MeshInstance3D


func _ready() -> void:
	SignalBus.toggle_gasmask_model.connect(toggle_model)


func toggle_model():
	print("hi")
	if self.visible:
		self.hide()
	else:
		self.show()
