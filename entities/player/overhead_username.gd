extends SubViewport


func _ready() -> void:
	if !is_multiplayer_authority():
		return
	else:
		get_parent().hide()
	
	$Label.text = Steam.getPersonaName()
