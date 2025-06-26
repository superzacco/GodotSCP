extends SubViewport


func _ready() -> void:
	$Label.text = Steam.getPersonaName()
