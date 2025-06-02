extends Node

const PACKET_READ_LIMIT: int = 32

var lobby_data
var lobby_ID: int = 0
var lobby_members: Array = []

var menuLobbyList: Control



func _ready() -> void:
	Steam.lobby_created.connect(_on_lobby_created)
	Steam.lobby_match_list.connect(_on_lobby_match_list)
	Steam.lobby_joined.connect(_on_lobby_joined)
	Steam.join_requested.connect(_on_lobby_join_requested)
	#Steam.lobby_chat_update.connect(_on_lobby_chat_update)
	#Steam.lobby_data_update.connect(_on_lobby_data_update)
	#Steam.lobby_invite.connect(_on_lobby_invite)
	#Steam.lobby_message.connect(_on_lobby_message)
	#Steam.persona_state_change.connect(_on_persona_change)
	
	check_command_line()


func create_lobby():
	if lobby_ID == 0:
		Steam.createLobby(Steam.LOBBY_TYPE_PUBLIC, SteamManager.lobbyMaxPlayers)


func check_command_line() -> void:
	var these_arguments: Array = OS.get_cmdline_args()
	
	# There are arguments to process
	if these_arguments.size() > 0:
		# A Steam connection argument exists
		if these_arguments[0] == "+connect_lobby":
			# Lobby invite exists so try to connect to it
			if int(these_arguments[1]) > 0:
				# At this point, you'll probably want to change scenes
				# Something like a loading into lobby screen
				print("Command line lobby ID: %s" % these_arguments[1])
				#join_lobby(int(these_arguments[1]))


func _on_lobby_created(connect: int, this_lobby_id: int) -> void:
	if connect == 1:
		# Set the lobby ID
		lobby_ID = this_lobby_id
		print("Created a lobby: %s" % lobby_ID)
		
		# Set this lobby as joinable, just in case, though this should be done by default
		Steam.setLobbyJoinable(lobby_ID, true)
		
		# Set some lobby data
		Steam.setLobbyData(lobby_ID, "name", SteamManager.steamUsername +"'s Lobby")
		Steam.setLobbyData(lobby_ID, "mode", "SCP Game Test")
		
		# Allow P2P connections to fallback to being relayed through Steam if needed
		var set_relay: bool = Steam.allowP2PPacketRelay(true)
		print("Allowing Steam to be relay backup: %s" % set_relay)


func on_open_lobby_list_pressed() -> void:
	# Set distance to worldwide
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	
	print("Requesting a lobby list")
	Steam.requestLobbyList()


func _on_lobby_match_list(these_lobbies: Array) -> void:
	# Erase previous entries
	for child in menuLobbyList.get_children():
		child.queue_free()
	
	for this_lobby in these_lobbies:
		# Pull lobby data from Steam, these are specific to our example
		var lobby_name: String = Steam.getLobbyData(this_lobby, "name")
		var lobby_mode: String = Steam.getLobbyData(this_lobby, "mode")
		
		# Get the current number of members
		var lobby_num_members: int = Steam.getNumLobbyMembers(this_lobby)
		
		# Create a button for the lobby
		var lobby_button: Button = Button.new()
		lobby_button.set_text("%s -- %s Player(s)" % [lobby_name, lobby_num_members])
		lobby_button.set_size(Vector2(400, 50))
		lobby_button.set_name("lobby_%s" % this_lobby)
		lobby_button.connect("pressed", Callable(self, "join_lobby").bind(this_lobby))
		
		lobby_button.autowrap_mode = TextServer.AUTOWRAP_WORD
		
		# Add the new lobby to the list
		menuLobbyList.add_child(lobby_button)


func join_lobby(this_lobby_id: int) -> void:
	if lobby_ID != 0:
		print("Already in Lobby! -- " + str(lobby_ID))
		return
	
	print("Attempting to join lobby %s" % this_lobby_id)
	
	# Clear any previous lobby members lists, if you were in a previous lobby
	lobby_members.clear()
	
	# Make the lobby join request to Steam
	Steam.joinLobby(this_lobby_id)


func _on_lobby_join_requested(this_lobby_id: int, friend_id: int) -> void:
	# Get the lobby owner's name
	var owner_name: String = Steam.getFriendPersonaName(friend_id)
	
	print("Joining %s's lobby..." % owner_name)
	
	# Attempt to join the lobby
	join_lobby(this_lobby_id)


func _on_lobby_joined(this_lobby_id: int, _permissions: int, _locked: bool, response: int) -> void:
	# If joining was successful
	if response == Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
		# Set this lobby ID as your lobby ID
		lobby_ID = this_lobby_id
			
		# Get the lobby members
		get_lobby_members()
		
		# Make the initial handshake
		make_p2p_handshake()
		
		print("Successfully Joined Lobby! " + str(lobby_ID))
		print(lobby_members)
		# Else it failed for some reason
	else:
		# Get the failure reason
		var fail_reason: String
		
		match response:
			Steam.CHAT_ROOM_ENTER_RESPONSE_DOESNT_EXIST: fail_reason = "This lobby no longer exists."
			Steam.CHAT_ROOM_ENTER_RESPONSE_NOT_ALLOWED: fail_reason = "You don't have permission to join this lobby."
			Steam.CHAT_ROOM_ENTER_RESPONSE_FULL: fail_reason = "The lobby is now full."
			Steam.CHAT_ROOM_ENTER_RESPONSE_ERROR: fail_reason = "Uh... something unexpected happened!"
			Steam.CHAT_ROOM_ENTER_RESPONSE_BANNED: fail_reason = "You are banned from this lobby."
			Steam.CHAT_ROOM_ENTER_RESPONSE_LIMITED: fail_reason = "You cannot join due to having a limited account."
			Steam.CHAT_ROOM_ENTER_RESPONSE_CLAN_DISABLED: fail_reason = "This lobby is locked or disabled."
			Steam.CHAT_ROOM_ENTER_RESPONSE_COMMUNITY_BAN: fail_reason = "This lobby is community locked."
			Steam.CHAT_ROOM_ENTER_RESPONSE_MEMBER_BLOCKED_YOU: fail_reason = "A user in the lobby has blocked you from joining."
			Steam.CHAT_ROOM_ENTER_RESPONSE_YOU_BLOCKED_MEMBER: fail_reason = "A user you have blocked is in the lobby."
		
		print("Failed to join this chat room: %s" % fail_reason)
		
		#Reopen the lobby list
		on_open_lobby_list_pressed()


func leave_lobby() -> void:
	# If in a lobby, leave it
	if lobby_ID != 0:
		# Send leave request to Steam
		Steam.leaveLobby(lobby_ID)
		
		# Wipe the Steam lobby ID then display the default lobby ID and player list title
		lobby_ID = 0
		
		# Close session with all users
	for this_member in lobby_members:
		# Make sure this isn't your Steam ID
		if this_member['steam_id'] != SteamManager.steamID:
			
			# Close the P2P session using the Networking class
			Steam.closeP2PSessionWithUser(this_member['steam_id'])
			
			# Clear the local lobby list
			lobby_members.clear()
		
		print("Left Lobby!")


func get_lobby_members() -> void:
	# Clear your previous lobby list
	lobby_members.clear()
	
	# Get the number of members from this lobby from Steam
	var num_of_members: int = Steam.getNumLobbyMembers(lobby_ID)
	
	# Get the data of these players from Steam
	for this_member in range(0, num_of_members):
		# Get the member's Steam ID
		var member_steam_id: int = Steam.getLobbyMemberByIndex(lobby_ID, this_member)
		
		# Get the member's Steam name
		var member_steam_name: String = Steam.getFriendPersonaName(member_steam_id)
		
		# Add them to the list
		lobby_members.append({"steam_id":member_steam_id, "steam_name":member_steam_name})


func send_p2p_packet(this_target: int, packet_data: Dictionary) -> void:
	# Set the send_type and channel
	var send_type: int = Steam.P2P_SEND_RELIABLE
	var channel: int = 0
	
	# Create a data array to send the data through
	var this_data: PackedByteArray
	this_data.append_array(var_to_bytes(packet_data))
	
	# If sending a packet to everyone
	if this_target == 0:
		# If there is more than one user, send packets
		if lobby_members.size() > 1:
		# Loop through all members that aren't you
			for this_member in lobby_members:
				if this_member['steam_id'] != SteamManager.steamID:
					Steam.sendP2PPacket(this_member['steam_id'], this_data, send_type, channel)
				
				# Else send it to someone specific
				else:
					Steam.sendP2PPacket(this_target, this_data, send_type, channel)
func make_p2p_handshake() -> void:
	print("Sending P2P handshake to the lobby")
	send_p2p_packet(0, {"message": "handshake", "from": SteamManager.steamID})
