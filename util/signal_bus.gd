extends Node

signal player_disconnected(id: int)
signal remove_player(id: int)

signal generate_level
signal level_generation_finished


signal win_game(time: String)
signal hide_main_menu
signal show_hidden_rooms

signal connect_elevator(elevator: Elevator)
signal reparent_item(item: Item)
signal setup_pd_release_point(point: PDReleasePoint)
signal activate_173
signal relocate_173
signal activate_106

signal teleport_173_to_player(position: Vector3)

signal send_player_to_106(player: Player)
signal toggle_gas_mask
signal toggle_gasmask_model
