extends Monster
class_name SCP049


func _ready() -> void:
	super()
	modelAnimations.animation_finished.connect(animation_finished)
	modelAnimations.play("sit")


func get_up():
	modelAnimations.play("getup")


func animation_finished(animName: String):
	if animName == "getup":
		set_active()
