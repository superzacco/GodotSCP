extends Control
class_name DebugInfo

@export var debug173: Label
var nearPlayer173: bool
var blinking173: bool
var looking173: bool
var relocationTimer: float

@export var debug106: Label
var summonTimer: float

func _ready() -> void:
	GlobalPlayerVariables.debugInfo = self
	$UpdateData.connect("timeout", update_info)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("f2"):
		if !self.visible:
			self.show()
		else:
			self.hide()


func update_info() -> void:
	debug173.text = "173 info:
					near player?: %s
					all players blinking?: %s
					all players looking away?: %s
					relocation timer: %s" % [nearPlayer173, blinking173, looking173, relocationTimer]
	
	debug106.text = "106 info:
					summon timer: %s" % summonTimer
	
	$UpdateData.start()
