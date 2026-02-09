extends VBoxContainer

var displayIdx: int = 0
var displayModesArr: Array = [
	"Windowed",
	"Borderless",
	"Fullscreen"
]
var displayModesDict: Dictionary = {
	"Windowed" : DisplayServer.WINDOW_MODE_WINDOWED,
	"Borderless" : DisplayServer.WINDOW_MODE_FULLSCREEN,
	"Fullscreen" : DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
}

var resIdx = 3
var resolutionsArr: Array = [
	"1920x1080",
	"1600x900",
	"1366x768",
	"1280x720",
	"1024x576",
	"640x360"
]
var resolutionsDict: Dictionary = {
	"1920x1080" : Vector2i(1920, 1080),
	"1600x900" : Vector2i(1600, 900),
	"1366x768" : Vector2i(1366, 768),
	"1280x720" : Vector2i(1280, 720),
	"1024x576" : Vector2i(1024, 576),
	"640x360" : Vector2i(640, 360)
}


func _ready() -> void:
	%WinText.text = str(displayModesArr[0])
	%ResText.text = str(resolutionsArr[3])


#region // DISPLAY & RESOLUTION
func _on_win_back_pressed() -> void:
	if (displayIdx-1) < 0:
		displayIdx = displayModesArr.size()
	
	displayIdx -= 1
	
	print(str(displayModesArr[displayIdx]))
	%WinText.text = str(displayModesArr[displayIdx])
	DisplayServer.window_set_mode(displayModesDict[displayModesArr[displayIdx]])
	DisplayServer.window_set_size(resolutionsDict[resolutionsArr[resIdx]])

func _on_win_advance_pressed() -> void:
	if (displayIdx+1) >= displayModesArr.size():
		displayIdx = -1
	
	displayIdx += 1
	
	print(str(displayModesArr[displayIdx]))
	%WinText.text = str(displayModesArr[displayIdx])
	DisplayServer.window_set_mode(displayModesDict[displayModesArr[displayIdx]])
	DisplayServer.window_set_size(resolutionsDict[resolutionsArr[resIdx]])

func _on_res_back_pressed() -> void:
	if (resIdx-1) < 0:
		resIdx = resolutionsArr.size()
	
	resIdx -= 1
	
	print(str(resolutionsArr[resIdx]))
	%ResText.text = str(resolutionsArr[resIdx])
	DisplayServer.window_set_size(resolutionsDict[resolutionsArr[resIdx]])

func _on_res_advance_pressed() -> void:
	if (resIdx+1) >= resolutionsArr.size():
		resIdx = -1
	
	resIdx += 1
	
	print(str(resolutionsArr[resIdx]))
	%ResText.text = str(resolutionsArr[resIdx])
	DisplayServer.window_set_size(resolutionsDict[resolutionsArr[resIdx]])
#endregion // DISPLAY & RESOLUTION


func _on_sens_slider_value_changed(value: float) -> void:
	GlobalPlayerVariables.sensitivity = ZFunc.remap(value, 0.1, 2.0)
	%SensNumber.text = str(GlobalPlayerVariables.sensitivity)


func _on_master_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(ZFunc.remap(value, 0.0, 1.0)))
	%MasterNumber.text = str(value) + "%"

func _on_sfx_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(1, linear_to_db(ZFunc.remap(value, 0.0, 1.0)))
	%SFXNumber.text = str(value) + "%"

func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(2, linear_to_db(ZFunc.remap(value, 0.0, 1.0)))
	%MusicNumber.text = str(value) + "%"
