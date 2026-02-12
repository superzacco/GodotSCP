extends Node3D

var busIdx: int
var effect: AudioEffectCapture
var playback: AudioStreamGeneratorPlayback

@export var inputThreshold: float
@export var voiceHoldDuration: float
var voiceHoldTimer := 0

@export var input: AudioStreamPlayer
@export var output: AudioStreamPlayer3D

var recievedBuffer := PackedFloat32Array()

func _ready() -> void:
	set_multiplayer_authority(self.get_parent().get_multiplayer_authority())
	
	if is_multiplayer_authority():
		busIdx = AudioServer.get_bus_index("Voice Input")
		effect = AudioServer.get_bus_effect(busIdx, 0)
	
	playback = output.get_stream_playback()


func _process(delta: float) -> void:
	if is_multiplayer_authority(): 
		if Input.is_action_pressed("voicetransmit"):
			process_mic_input()
	
	process_voice_chat()


func process_voice_chat():
	if recievedBuffer.size() <= 0:
		#print_debug("player %s recieving no voice data!" % get_multiplayer_authority())
		return
	
	for i in range(min(playback.get_frames_available(), recievedBuffer.size())):
		playback.push_frame(Vector2(recievedBuffer[0], recievedBuffer[0]))
		recievedBuffer.remove_at(0)


func process_mic_input():
	#print_debug("Player: %s using push-to-talk" % get_multiplayer_authority())
	
	var data = PackedFloat32Array()
	var squareSum := 0.0
	
	var stereoData: PackedVector2Array = effect.get_buffer(effect.get_frames_available())
	if stereoData.size() > 0:
		data.resize(stereoData.size())
		
		for i in range(stereoData.size()):
			var val = (stereoData[i].x + stereoData[i].y) / 2
			data[i] = val
			squareSum += val * val
	
	var rms = sqrt(squareSum / stereoData.size())
	
	if rms > inputThreshold:
		voiceHoldTimer = voiceHoldDuration
	else:
		voiceHoldTimer -= get_process_delta_time()
	
	if voiceHoldTimer > 0.0:
		print("sending data")
		send_data.rpc(data)


@rpc("any_peer", "call_remote", "unreliable_ordered")
func send_data(data: PackedFloat32Array):
	print("sender: %s, reciever %s" % [multiplayer.get_remote_sender_id(), multiplayer.get_unique_id()])
	recievedBuffer.append_array(data)
