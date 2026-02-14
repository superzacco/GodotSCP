extends Node3D


func equip():
	SignalBus.toggle_gas_mask_overlay.emit()
	toggle_model_for_others.rpc()
	$equipsound.play()


@rpc("any_peer", "call_remote", "reliable")
func toggle_model_for_others():
	SignalBus.toggle_gasmask_model.emit()
