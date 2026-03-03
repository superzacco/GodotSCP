extends Paper

@export var otherDocument: PackedScene
@export var code: int = 0

func equip():
	SignalBus.equip_paper.emit(paper, otherDocument)
