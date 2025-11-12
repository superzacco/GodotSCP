extends Node3D

var corrosivesInRange: Array[CorrosiveDecal]

@export var stepSounds: Array[AudioStream]
@export var corrosiveStepSounds: Array[AudioStream]

var playback: AudioStreamPlaybackPolyphonic

func _ready() -> void:
	playback = $Steps.get_stream_playback()

func step():
	var clip: AudioStream
	if corrosivesInRange.size() > 0 or GlobalPlayerVariables.inPocketDimension == true:
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
