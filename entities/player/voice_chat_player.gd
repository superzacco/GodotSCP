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
var sendBuffer := PackedFloat32Array()
@export var sampleChunkTarget: int = 2048
@export var sampleChunkLimit: int = 8192

func _ready() -> void:
	set_multiplayer_authority(self.get_parent().get_multiplayer_authority())
	
	if is_multiplayer_authority():
		busIdx = AudioServer.get_bus_index("Voice Input")
		effect = AudioServer.get_bus_effect(busIdx, 0)
	
	playback = output.get_stream_playback()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("voicetransmit"):
		sync_mix_rate.rpc(int(AudioServer.get_mix_rate()))


func _process(delta: float) -> void:
	if is_multiplayer_authority(): 
		if GlobalPlayerVariables.usePTT:
			if Input.is_action_pressed("voicetransmit"):
				process_mic_input(delta)
			
		else: process_mic_input(delta)
	
	
	process_voice_chat()


func process_voice_chat():
	if recievedBuffer.size() <= 0:
		return
	
	if recievedBuffer.size() > sampleChunkLimit:
		var excess = recievedBuffer.size() - sampleChunkTarget
		recievedBuffer = recievedBuffer.slice(excess)
	
	var framesToPush = min(playback.get_frames_available(), recievedBuffer.size())
	
	for i in range(framesToPush):
		var val = recievedBuffer[i]
		playback.push_frame(Vector2(val, val))
	
	recievedBuffer = recievedBuffer.slice(framesToPush)


func process_mic_input(delta: float):
	#print_debug("Player: %s using push-to-talk" % get_multiplayer_authority())
	
	var stereoData: PackedVector2Array = effect.get_buffer(effect.get_frames_available())
	if stereoData.size() > 0:
		var squareSum := 0.0
		for i in range(stereoData.size()):
			var val = (stereoData[i].x + stereoData[i].y) / 2
			sendBuffer.append(val)
			squareSum += val * val
		
		var rms = sqrt(squareSum / stereoData.size())
		if rms > inputThreshold:
			voiceHoldTimer = voiceHoldDuration
		else:
			voiceHoldTimer -= delta
	
	if sendBuffer.size() >= sampleChunkTarget:
		if voiceHoldTimer > 0.0:
			send_data.rpc(compress_audio(sendBuffer))
		
		sendBuffer.clear()


func compress_audio(f32Data: PackedFloat32Array) -> PackedByteArray:
	var byteData := PackedByteArray()
	byteData.resize(f32Data.size())
	
	for i in range(f32Data.size()):
			var sample = clamp(f32Data[i], -1.0, 1.0)
			byteData[i] = int((sample + 1.0) * 127.5)
	
	return byteData

func decompress_audio(byteData: PackedByteArray) -> PackedFloat32Array:
	var f32Data = PackedFloat32Array()
	f32Data.resize(byteData.size())
	
	for i in range(byteData.size()):
		f32Data[i] = (float(byteData[i]) / 127.5) - 1.0
	
	return f32Data


@rpc("any_peer", "call_remote", "reliable")
func sync_mix_rate(rate: int):
	if output.stream is not AudioStreamGenerator:
		return
	
	var streamGenerator: AudioStreamGenerator = output.stream
	
	output.stop()
	streamGenerator.mix_rate_mode = AudioStreamGenerator.MIX_RATE_CUSTOM
	streamGenerator.mix_rate = rate
	output.play()
	
	playback = output.get_stream_playback()

@rpc("any_peer", "call_remote", "unreliable_ordered")
func send_data(data: PackedByteArray):
	print("sender: %s, reciever %s" % [multiplayer.get_remote_sender_id(), multiplayer.get_unique_id()])
	recievedBuffer.append_array(decompress_audio(data))
