extends Node
class_name AudioMgr


func play_sound(soundClip: AudioStream, position: Vector3):
	var audioPlayer = AudioStreamPlayer3D.new()
	self.add_child(audioPlayer)
	audioPlayer.global_position = position
	audioPlayer.stream = soundClip
	
	await audioPlayer.finished
	audioPlayer.queue_free()
