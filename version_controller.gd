extends Control

var buildVersion: int
var versionInfoFile = "res://versioninfo.txt"

func _ready() -> void:
	
	
	var fileRead = FileAccess.open(versionInfoFile, FileAccess.READ)
	buildVersion = fileRead.get_as_text().to_int()
	print(buildVersion)
	
	buildVersion += 1
	
	var fileWrite = FileAccess.open(versionInfoFile, FileAccess.WRITE)
	fileWrite.store_string(str(buildVersion))
