extends Node

var buildVersion: int
var versionInfoFile = "res://versioninfo.txt"

func _init() -> void:
	var fileRead = FileAccess.open(versionInfoFile, FileAccess.READ)
	buildVersion = fileRead.get_as_text().to_int()
	print("build " + str(buildVersion))
	
	if OS.is_debug_build():
		buildVersion += 1
		
		var fileWrite = FileAccess.open(versionInfoFile, FileAccess.WRITE)
		fileWrite.store_string(str(buildVersion))
