extends Node

# Signals to communicate with the game UI and logic
signal move_confirmed(origin: Vector2i, destination: Vector2i, new_turn: String)
signal move_error(reason: String)
signal combat_result(result_data: Dictionary)
signal color_assigned(color: String)
signal match_started()
signal combat_started(origin: Vector2i, destination: Vector2i, attacker: String)

var connection := StreamPeerTCP.new()
var is_connected_to_server := false
var local_player_id = ""

const SERVER_IP = "127.0.0.1" # Change this to the real server IP later
const PORT = 7777


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	connect_to_server()

func connect_to_server():
	var err = connection.connect_to_host(SERVER_IP, PORT)
	if err == OK:
		print("Connecting to server...")

func _process(_delta):
	connection.poll()
	var status = connection.get_status()
	if status == StreamPeerTCP.STATUS_CONNECTED:
		if not is_connected_to_server:
			is_connected_to_server = true
			print("Successfully connected to the server!")
			
		# Read all available packets
		while connection.get_available_bytes() > 0:
			var data = connection.get_var()
			print(data)
			if typeof(data) == TYPE_STRING:
				process_server_packet(data)
				
	elif status == StreamPeerTCP.STATUS_ERROR or status == StreamPeerTCP.STATUS_NONE:
		if is_connected_to_server:
			is_connected_to_server = false
			print("Disconnected from the server.")

func process_server_packet(json_string: String):
	var json = JSON.new()
	if json.parse(json_string) == OK:
		var packet = json.data
		print(packet,"\n")
		if typeof(packet) == TYPE_DICTIONARY and packet.has("message_type"):
			match packet["message_type"]:
				"move_confirmation":
					var orig = Vector2i(packet["origin"]["x"], packet["origin"]["y"])
					var dest = Vector2i(packet["destination"]["x"], packet["destination"]["y"])
					move_confirmed.emit(orig, dest, packet["new_turn"])
				"move_error":
					move_error.emit(packet["reason"])
				"combat_result":
					combat_result.emit(packet)
				"welcome":
					local_player_id = packet["assigned_color"]
					color_assigned.emit(packet["assigned_color"])
				"match_start":
					match_started.emit()
				"combat_start":
					var orig = Vector2i(packet["origin"]["x"], packet["origin"]["y"])
					var dest = Vector2i(packet["destination"]["x"], packet["destination"]["y"])
					combat_started.emit(orig, dest, packet["attacker"])

# Helper function to send data
func send_json(dict: Dictionary):
	if connection.get_status() == StreamPeerTCP.STATUS_CONNECTED:
		connection.put_var(JSON.stringify(dict))

# Functions called by pieces.gd and rpg.gd
func send_move_action(origin: Vector2i, dest: Vector2i, player_id: String):
	send_json({
		"message_type": "move_action",
		"player_id": player_id,
		"origin": {"x": origin.x, "y": origin.y},
		"destination": {"x": dest.x, "y": dest.y}
	})

func send_combat_action(action: String, player_id: String):
	send_json({
		"message_type": "combat_action",
		"player_id": player_id,
		"chosen_action": action
	})
