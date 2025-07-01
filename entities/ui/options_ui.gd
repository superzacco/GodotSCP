extends VBoxContainer


func _on_sens_slider_value_changed(value: float) -> void:
	GlobalPlayerVariables.sensitivity = ZFunc.clamp_between(value, 0.1, 2.0)
	%SensNumber.text = str(GlobalPlayerVariables.sensitivity)


func _on_master_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(ZFunc.clamp_between(value, 0.0, 1.0)))
	%MasterNumber.text = str(value) + "%"

func _on_sfx_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(1, linear_to_db(ZFunc.clamp_between(value, 0.0, 1.0)))
	%SFXNumber.text = str(value) + "%"

func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(2, linear_to_db(ZFunc.clamp_between(value, 0.0, 1.0)))
	%MusicNumber.text = str(value) + "%"
