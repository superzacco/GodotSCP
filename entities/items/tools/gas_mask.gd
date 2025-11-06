extends Node3D

func equip():
	SignalBus.toggle_gas_mask.emit()
	$equipsound.play()
