extends Node
class_name AmbienceManager

var soundsPlayerAPlayback: AudioStreamPlaybackPolyphonic
var musicPlayerBPlayback: AudioStreamPlaybackPolyphonic

@export var musicPlayerA: AudioStreamPlayer
@export var musicPlayerB: AudioStreamPlayer
@export var soundsPlayerA: AudioStreamPlayer
@export var soundsPlayerB: AudioStreamPlayer
@export var ambiencePlayerA: AudioStreamPlayer
@export var ambiencePlayerB: AudioStreamPlayer
@export var ambiencePlayerC: AudioStreamPlayer

@export var randomAmbience: Array[AudioStream]
@export var Intercom079Ambiance: Array[AudioStream]

@export var LConMusic: AudioStream
@export var fullSiteLockdown: AudioStream

@export var spawnInSound: AudioStream


func _ready() -> void:
	musicPlayerBPlayback = musicPlayerB.get_stream_playback()
	soundsPlayerAPlayback = soundsPlayerA.get_stream_playback()
	
	GlobalPlayerVariables.ambienceManager = self
	
	await SignalBus.generate_level
	
	musicPlayerA.stream = LConMusic
	musicPlayerA.play()
	
	#ambiencePlayerA.stream = fullSiteLockdown
	#ambiencePlayerA.play()
	
	soundsPlayerA.stream = spawnInSound
	soundsPlayerA.play()
	
	play_random_ambience()


func play_random_ambience(quicker: bool = false):
	if !quicker:
		$AmbienceTimer.start(randi_range(30, 60))
	else:
		$AmbienceTimer.start(randi_range(15, 30))
	await $AmbienceTimer.timeout
	
	quicker = false
	
	if ZFunc.randInPercent(8):
		quicker = true
		ambiencePlayerB.stream = Intercom079Ambiance[randi_range(0, Intercom079Ambiance.size()-1)]
	else:
		ambiencePlayerB.stream = randomAmbience[randi_range(0, randomAmbience.size()-1)]
	ambiencePlayerB.play()
	
	play_random_ambience()


#region // SCP/ROOM AMBIANCE MUSIC TRACKS
func play_music_ambiance(clip: AudioStream):
	cancel_current_music_ambiance()
	musicPlayerBPlayback.play_stream(clip)

func cancel_current_music_ambiance(fadeDuration: float = 0.0):
	if fadeDuration > 0.0:
		fade_current_music_ambiance(fadeDuration)
		return
	
	musicPlayerBPlayback.stop()

func fade_current_music_ambiance(duration: int):
	ZFunc.fade_out(musicPlayerB, duration)
#endregion


# // NON-POSITIONAL SOUNDS
func play_sound(clip: AudioStream):
	print(soundsPlayerAPlayback, clip)
	soundsPlayerAPlayback.play_stream(clip)


# // FOR 173 SCRAPING
func play_ambience(clip: AudioStream):
	ambiencePlayerC.stream = clip
	ambiencePlayerC.play()
