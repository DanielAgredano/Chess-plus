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
	pass

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

func press(op):
	if turn == null: return
	var defends = ["Blue","Red"].find(turn)
	var attacks = ["Red","Blue"].find(turn)
	if op == 'A':
		hp[defends] -= 0.2 * def[defends]
		bars[defends].update(hp[defends])
		def[defends] = 1.0
		P_hit.position = positions[defends].position
		P_hit.emitting = true
		$"../Sound".playSound("hit")
	if op == 'S':
		var bonus = 1.0 + float(adv[attacks])
		hp[defends] -= 0.2 * bonus * def[defends]
		bars[defends].update(hp[defends])
		def[defends] = 1.0
		P_sp.position = positions[defends].position
		P_sp.emitting = true
		$"../Sound".playSound("special")
	if op == 'D':
		if def[attacks] == 0.5: return
		def[attacks] = 0.5
		$"../Sound".playSound("shield")
	if op == 'R':
		if crit == []:
			crit = [0,0,0]
			crit[randi_range(0,len(crit)-1)] = 1
		if crit[0]:
			hp[defends] -= 0.6 * def[defends]
			bars[defends].update(hp[defends])
			def[defends] = 1.0
			P_crit.position = positions[defends].position
			P_crit.emitting = true
			$"../Sound".playSound("crit")
		crit.remove_at(0)
	#Turn end
	if hp[defends] <= 0.01:
		get_tree().paused = false
		$"../Actions/Animation".play_backwards("Open")
		$Anim.play_backwards("intro")
		Pieces.capture(turn == startTurn)
		turn = null
		P_adv.emitting = false
		for s in range(2): P_shields[s].emitting = false
	else:
		turn = {"Blue":"Red","Red":"Blue"}[turn]
		updatePalette()
		P_adv.emitting = adv[defends]
		for s in range(2): P_shields[s].emitting = (def[s] == 0.5)
	return true

func updatePalette():
	for i in $"../Actions/Sprites".get_children():
		i.material.set_shader_parameter("idx",["Blue","Red"].find(turn))

func _process(delta):
	pass
