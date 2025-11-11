extends RigidBody3D

func _ready() -> void:
	$"106/AnimationPlayer".play("rise")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	$"106/AnimationPlayer".play(anim_name)
