extends TextureRect

func  _ready() -> void:
	SignalBus.toggle_gas_mask_overlay.connect(toggle_overlay)


func toggle_overlay():
	if !self.visible:
		self.show()
		GlobalPlayerVariables.wearingGasMask = true
	else:
		self.hide()
		GlobalPlayerVariables.wearingGasMask = false
