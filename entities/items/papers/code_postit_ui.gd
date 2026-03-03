extends Control

var code: int = 0
@export var codeLabel: Label

func _ready() -> void:
	codeLabel.text = str(code)
