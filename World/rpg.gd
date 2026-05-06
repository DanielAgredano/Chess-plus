extends ColorRect

@onready var Pieces = $"../Pieces"
@onready var bars = [$HP/Bar1,$HP/Bar2]

@onready var P_adv = $"../Actions/Effects/Advantage"
@onready var P_shields = [
	$"../Actions/Effects/Shield",
	$"../Actions/Effects/Shield2"]
@onready var P_hit = $"../Actions/Effects/Hit"
@onready var P_crit = $"../Actions/Effects/Crit"
@onready var P_sp = $"../Actions/Effects/Special"
@onready var positions = $Pos.get_children()

var turn
var startTurn
var red
var blue
var hp = [1.0,1.0]#red,blue
var def = [1.0,1.0]
var adv = [false,false]
var clss
var pieces
var coords
var crit = []
var CLASS = {
	'P':'W',#Warrior
	'T':'W',#Warrior
	'H':'S',#Strategist
	'B':'M',#Magician
	'Q':'M',#Magician
	'K':'S',#Strategist
}
var WEAKNESS = {
	'W':'S',
	'S':'M',
	'M':'W',
}

func _ready():
	NetworkManager.combat_result.connect(_on_combat_result)
	NetworkManager.combat_started.connect(_on_combat_started)

func _on_combat_started(origin: Vector2i, destination: Vector2i, attacker: String):
	coords = [origin,destination]
	start(Pieces.getPiece(origin), Pieces.getPiece(destination), attacker)

func start(sel,vec,_turn):
	turn = _turn
	startTurn = turn
	if turn == "Red":
		red = sel
		blue = vec
	else:
		red = vec
		blue = sel
	hp = [1.0,1.0]
	def = [1.0,1.0]
	bars[0].update(1.0)
	bars[1].update(1.0)
	updatePalette()
	get_tree().paused = true
	$Anim.play("intro")
	$"../Actions/Animation".play("Open")
	$Characters/C1.play(red.name.left(1))
	$Characters/C2.play(blue.name.left(1))
	clss = [CLASS[red.name.left(1)],CLASS[blue.name.left(1)]]
	adv[0] = (WEAKNESS[clss[0]] == clss[1])
	adv[1] = (WEAKNESS[clss[1]] == clss[0])
	P_adv.emitting = adv[["Red","Blue"].find(turn)]

func press(op: String):
	if turn == null or turn != $"../Pieces".local_player_id: 
		return
	#print(op," ",$"../Pieces".local_player_id)
	NetworkManager.send_combat_action(op, turn)

# Triggered ONLY when the server sends the calculation back
func _on_combat_result(data: Dictionary):
	var action = data["action"]
	var is_crit = data["is_crit"]
	
	# Find who was defending to update their particles/UI
	var defends_idx = 1 if data["attacker"] == "Red" else 0
	
	# 1. Update visual HP Bars with the exact numbers the server dictated
	bars[0].update(data["new_hp_red"])
	bars[1].update(data["new_hp_blue"])
	
	# 2. Play matching sounds and particles based on the action and crit flag
	match action:
		'A':
			P_hit.position = positions[defends_idx].position
			P_hit.emitting = true
			$"../Sound".playSound("hit")
			P_shields[defends_idx].emitting = false
		'S':
			P_sp.position = positions[defends_idx].position
			P_sp.emitting = true
			$"../Sound".playSound("special")
		'D':
			$"../Sound".playSound("shield")
			P_shields[1 - defends_idx].emitting = true
		'R':
			if is_crit:
				P_crit.position = positions[defends_idx].position
				P_crit.emitting = true
				$"../Sound".playSound("crit")
			else:
				# Normal hit if roulette failed
				P_hit.position = positions[defends_idx].position
				P_hit.emitting = true
				$"../Sound".playSound("hit")

	# 3. Handle battle end or turn change
	if data["battle_ended"]:
		get_tree().paused = false
		$"../Actions/Animation".play_backwards("Open")
		$Anim.play_backwards("intro")
		if data["attacker_won"]:
			var attacker = data["attacker"]
			var attacker_ref = red if attacker == "Red" else blue
			var defender_ref = blue if attacker == "Red" else red
			attacker_ref.position = defender_ref.position
			Pieces.captureKing(defender_ref)
			defender_ref.queue_free()
			Pieces.board[coords[1].x][coords[1].y]=attacker_ref
			Pieces.board[coords[0].x][coords[0].y]=null
			Pieces.moveSelection(null)
		else:
			pass
		P_adv.emitting = false
		for s in range(2): P_shields[s].emitting = false
		Pieces.changeTurn()
	else:
		# Update turn visuals if combat continues
		turn = "Blue" if data["attacker"] == "Red" else "Red"
		updatePalette()

func updatePalette():
	for i in $"../Actions/Sprites".get_children():
		i.material.set_shader_parameter("idx",["Blue","Red"].find(turn))

func _process(delta):
	pass
