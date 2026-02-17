extends Node3D

var corrosivesInRange: Array[CorrosiveDecal]

@export var stepSounds: Array[AudioStream]
@export var corrosiveStepSounds: Array[AudioStream]

var playback: AudioStreamPlaybackPolyphonic

func _ready() -> void:
	playback = $Steps.get_stream_playback()

func step():
	var isStepCorrosive: bool = corrosivesInRange.size() > 0 or GlobalPlayerVariables.inPocketDimension == true
	play_step_sound.rpc(isStepCorrosive)


@rpc("authority", "call_local", "reliable")
func play_step_sound(isCorrosive: bool):
	var clip: AudioStream = null
	
	if isCorrosive:
		clip = ZFunc.rand_from(corrosiveStepSounds)
	else:
		clip = ZFunc.rand_from(stepSounds)
	
	playback.play_stream(clip)


func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("corrosive"):
		corrosivesInRange.append(area)

func _on_area_exited(area: Area3D) -> void:
	if area.is_in_group("corrosive"):
		corrosivesInRange.erase(area)
