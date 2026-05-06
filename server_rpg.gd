extends Node

const CLASSES = {
	'P':'W', # Warrior
	'T':'W', # Warrior
	'H':'S', # Strategist
	'B':'M', # Magician
	'Q':'M', # Magician
	'K':'S', # Strategist
}

const WEAKNESSES = {
	'W':'S',
	'S':'M',
	'M':'W',
}

var hp := [1.0, 1.0] # [Red HP, Blue HP]
var def_modifier := [1.0, 1.0] # [Red Def, Blue Def]
var advantage := [false, false] # [Red Adv, Blue Adv]
var crit_pool := []

var current_turn := ""
var start_turn := ""
var is_battling := false

# Called by NetworkManager when a battle starts on the board
func start_combat(attacker_type: String, defender_type: String, turn: String) -> void:
	is_battling = true
	current_turn = turn
	start_turn = turn
	
	hp = [1.0, 1.0]
	def_modifier = [1.0, 1.0]
	crit_pool.clear()
	
	# Determine which team corresponds to which piece
	var red_type = attacker_type if turn == "Red" else defender_type
	var blue_type = attacker_type if turn == "Blue" else defender_type
	
	var red_class = CLASSES[red_type.left(1)]
	var blue_class = CLASSES[blue_type.left(1)]
	
	# Calculate advantage
	advantage[0] = (WEAKNESSES[red_class] == blue_class)
	advantage[1] = (WEAKNESSES[blue_class] == red_class)


# Called by NetworkManager when it receives an "accion_combate" JSON packet
func process_action(op: String, player_id: String) -> Dictionary:
	# Validate if it's actually their turn
	if not is_battling or player_id != current_turn:
		return {"is_valid": false}
		
	var defends_idx = ["Blue", "Red"].find(current_turn)
	var attacks_idx = ["Red", "Blue"].find(current_turn)
	
	var result = {
		"is_valid": true,
		"action": op,
		"attacker": current_turn,
		"is_crit": false,
		"battle_ended": false,
		"attacker_won": false
	}
	
	match op:
		'A': # Attack
			hp[defends_idx] -= 0.2 * def_modifier[defends_idx]
			def_modifier[defends_idx] = 1.0
			
		'S': # Special
			var bonus = 1.0 + float(advantage[attacks_idx])
			hp[defends_idx] -= 0.2 * bonus * def_modifier[defends_idx]
			def_modifier[defends_idx] = 1.0
			
		'D': # Defend
			if def_modifier[attacks_idx] == 0.5:
				return {"is_valid": false} # Cannot defend twice
			def_modifier[attacks_idx] = 0.5
			
		'R': # Roulette / Crit
			if crit_pool.is_empty():
				crit_pool = [0, 0, 0]
				crit_pool[randi_range(0, 2)] = 1
				
			if crit_pool[0] == 1:
				hp[defends_idx] -= 0.6 * def_modifier[defends_idx]
				result["is_crit"] = true
				
			def_modifier[defends_idx] = 1.0
			crit_pool.pop_front()
			
	# Save updated HP into result dictionary
	result["new_hp_red"] = hp[0]
	result["new_hp_blue"] = hp[1]
	
	# Check if combat has ended
	if hp[defends_idx] <= 0.01:
		is_battling = false
		result["battle_ended"] = true
		result["attacker_won"] = (current_turn == start_turn)
		current_turn = ""
	else:
		# Change turn
		current_turn = "Blue" if current_turn == "Red" else "Red"
		result["next_turn"] = current_turn
		
	return result
