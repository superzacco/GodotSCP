extends Monster
class_name SCP106

var chasing: bool = false
var captured: bool = false

@export var minSpawnTime: int 
@export var maxSpawnTime: int 

@export var corrosiveDecal: PackedScene

@export var summonTimer: Timer
@export var corrosiveDecalTimer: Timer 

@export var risingPlayer: AudioStreamPlayer3D
@export var slopSoundsPlayer: AudioStreamPlayer3D
@export var breathingPlayer: AudioStreamPlayer3D
@export var chasePlayer: AudioStreamPlayer
@export var PDSendPlayer: AudioStreamPlayer

@export var emergeSounds: Array[AudioStream]

var debugInfo: DebugInfo = null


func _ready() -> void:
	super()
	SignalBus.activate_106.connect(on_106_activated)
	corrosiveDecalTimer.timeout.connect(spawn_repeating_decal)
	summonTimer.timeout.connect(on_106_activated)
	$CollisionShape3D.position += Vector3(0, -15, 0)
	
	await SignalBus.level_generation_finished
	
	GlobalPlayerVariables.facilityManager.scp106 = self
	debugInfo = GlobalPlayerVariables.debugInfo
	
	if multiplayer.is_server():
		wait_to_summon.rpc(randf_range(minSpawnTime, maxSpawnTime))


func process_one() -> void:
	super()


func _physics_process(delta: float) -> void:
	super(delta)
	if !should_process(): return
	
	process_client()
	
	if !multiplayer.is_server(): return
	
	process_server()


func process_client():
	if debugInfo: debugInfo.summonTimer = summonTimer.time_left

func process_server():
	pass


func should_process() -> bool:
	super()
	if !chasing or captured: 
		return false
	else: return true

func attack():
	end_chase.rpc()
	super()

func on_106_activated():
	enabled = true
	rise.rpc(GlobalPlayerVariables.playerPosition)

func on_106_contained():
	summonTimer.stop()
	ZFunc.fade_out(breathingPlayer, 4.0)
	ZFunc.fade_out(slopSoundsPlayer, 4.0)
	
	chasePlayer.play(20.0)
	ZFunc.fade_in(chasePlayer, 5.0)
	await get_tree().create_timer(7.5).timeout
	ZFunc.fade_out(chasePlayer, 7.5)


@rpc("any_peer", "call_local", "reliable")
func rise(summonPos: Vector3):
	summonTimer.stop()
	
	slopSoundsPlayer.stream = ZFunc.rand_from(emergeSounds)
	slopSoundsPlayer.play()
	
	breathingPlayer.play()
	ZFunc.fade_in(breathingPlayer, 5.0)
	
	risingPlayer.play()
	ZFunc.fade_in(risingPlayer, 2.0)
	
	self.global_position = summonPos
	
	modelAnimations.stop()
	modelAnimations.play("rise")
	spawn_first_decal()
	
	await modelAnimations.animation_finished
	
	if !captured: begin_chase()
	else: on_106_contained()


@rpc("any_peer", "call_local", "reliable")
func begin_chase(atPosition := Vector3.ZERO):
	print("106 beginning chase")
	chasePlayer.play()
	
	if atPosition != Vector3.ZERO:
		self.global_position = atPosition
	
	chasing = true
	$CollisionShape3D.position += Vector3(0, 15, 0)
	modelAnimations.play("walk")
	
	corrosiveDecalTimer.start()


@rpc("any_peer", "call_local", "reliable")
func end_chase():
	if !chasing: return
	print("106 ending chase")
	ZFunc.fade_out(chasePlayer, 5.0)
	breathingPlayer.stop()
	
	chasing = false
	$CollisionShape3D.position += Vector3(0, -15, 0)
	
	corrosiveDecalTimer.stop()
	spawn_first_decal()
	
	modelAnimations.stop()
	modelAnimations.play_backwards("rise")
	
	if multiplayer.is_server():
		wait_to_summon.rpc(randf_range(minSpawnTime, maxSpawnTime))


@rpc("any_peer", "call_local", "reliable")
func wait_to_summon(summonTime: float):
	summonTimer.start(summonTime)


func on_send_player_to_pd(player: Player):
	player.take_damage(25.0, Damage.Types.TYPE_106)
	PDSendPlayer.play()


func spawn_first_decal():
	var corrode: CorrosiveDecal = corrosiveDecal.instantiate()
	get_tree().root.add_child(corrode)
	
	corrode.global_position = self.global_position
	corrode.finalSize = 3.5


func spawn_repeating_decal():
	if !chasing:
		corrosiveDecalTimer.stop()
		return
	
	var randomSize = randf_range(1.25, 1.75)
	var corrode: CorrosiveDecal = corrosiveDecal.instantiate()
	
	get_tree().root.add_child(corrode)
	corrode.global_position = self.global_position
	
	corrode.speed = 2.0
	corrode.finalSize = randomSize



func stop_pd_ambiance():
	ZFunc.fade_out($PDAmbiance, 5.0)


func _on_chase_radius_area_exited(area: Area3D) -> void:
	if area.is_in_group("noclip_player_area"):
		if playersInChaseRadius.size() <= 0:
			end_chase.rpc()


func _on_teleportzone_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and chasing == true:
		var player: Player = body
		on_send_player_to_pd(player)
