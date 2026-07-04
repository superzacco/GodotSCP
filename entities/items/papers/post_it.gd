extends Paper
#PostIT


var codeMade = false
@export var code: String = "0000"

var facilityMGR: FacilityManager = null
func _ready() -> void:
	await SignalBus.level_generation_finished
	facilityMGR = GlobalPlayerVariables.facilityManager


func equip():
	if code == "0000": pick_code.rpc()
	while codeMade == false:
		await get_tree().create_timer(0.1).timeout
	
	SignalBus.equip_paper.emit(paper, {PaperUI.OtherDataTypes.POST_IT_CODES: code})


@rpc("any_peer", "call_local", "reliable")
func pick_code():
	if !multiplayer.is_server(): return
	var codeDict: Dictionary = facilityMGR.LConHConCheckpointOverrideCodes
	var dictSize: int = codeDict.size()
	var pickedCode = codeDict[randi_range(0, dictSize-1)]
	set_code.rpc(pickedCode)


@rpc("any_peer", "call_local", "reliable")
func set_code(pickedCode: String):
	code = pickedCode
	codeMade = true
