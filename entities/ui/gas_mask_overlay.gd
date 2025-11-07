extends TextureRect

func  _ready() -> void:
	SignalBus.toggle_gas_mask.connect(toggle_overlay)


func toggle_overlay():
	toggle_model_for_others.rpc()
	print("here")
	
	if !self.visible:
		self.show()
		GlobalPlayerVariables.wearingGasMask = true
	else:
		self.hide()
		GlobalPlayerVariables.wearingGasMask = false


@rpc("reliable", "call_remote")
func toggle_model_for_others():
	SignalBus.toggle_gasmask_model.emit()
