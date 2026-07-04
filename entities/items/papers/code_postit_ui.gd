extends Control
class_name PostITDisplay

var code: String = "0000":
	set(v):
		code = v
		codeLabel.text = code
@export var codeLabel: Label
