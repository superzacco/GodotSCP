extends Node

signal player_disconnected(id: int)
signal remove_player(id: int)

signal spawn_player(id: int)

signal win_game(time: String)
signal hide_main_menu


# // COMMUNICATION // #
signal equip_paper(texture: Texture2D)
signal setup_pd_release_point(point: PDReleasePoint)
signal connect_elevator(elevator: Elevator)
signal setup_body(id: String)
signal reparent_item(item: Item)
signal hide_inventory


# // DEBUG/COMMANDS // #
signal teleport_173_to_player(position: Vector3)
signal activate_173
signal relocate_173
signal activate_106
signal show_hidden_rooms

signal generate_level
signal level_generation_finished


signal send_player_to_106(player: Player)
signal toggle_gas_mask
signal toggle_gasmask_model
