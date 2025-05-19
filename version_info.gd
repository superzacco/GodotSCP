extends Control

@export var versionString: Label
@export var version: String

func _ready() -> void:
	versionString.text = (version + " | build version: " + str(VersionController.buildVersion))
