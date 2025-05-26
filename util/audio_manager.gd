extends Node

func play_sound(soundClip: AudioStream, audioBus: String, position: Vector3, volume: int = -6.0, worldSound: bool = false):
	var audioPlayer = AudioStreamPlayer3D.new()
	self.add_child(audioPlayer)
	audioPlayer.global_position = position
	
	audioPlayer.bus = audioBus
	audioPlayer.volume_db = volume
	if worldSound == false:
		audioPlayer.attenuation_model = AudioStreamPlayer3D.ATTENUATION_DISABLED
	
	await audioPlayer.finished
	audioPlayer.queue_free()
