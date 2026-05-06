extends Node

var board = []
var turn = "Blue"

func _ready():
	setup_board()

func setup_board():
	board.clear()
	for i in range(8):
		board.append([null, null, null, null, null, null, null, null])
	
	var back_row = ["T", "H", "B", "Q", "K", "B", "H", "T"]
	
	for i in range(8):
		board[i][0] = {"team": "Red", "type": back_row[i]}
		board[i][1] = {"team": "Red", "type": "P"} # Peones rojos
		
		board[i][6] = {"team": "Blue", "type": "P"} # Peones azules
		board[i][7] = {"team": "Blue", "type": back_row[i]}

func getPiece(vec: Vector2i):
	return board[vec.x][vec.y]

func getTeam(piece: Dictionary):
	return piece["team"]

func checkJumps(sel: Vector2i, vec: Vector2i):
	var diff = vec - sel
	var step = Vector2i(sign(diff.x), sign(diff.y))
	var current = sel + step
	while current != vec:
		if getPiece(current) != null:
			return true
		current += step
	return false

func checkMove(sel: Vector2i, vec: Vector2i) -> bool:
	var piece = getPiece(sel)
	if piece == null: return false
	
	var type = piece["type"]
	
	if type == 'P':
		var dir = -1 if getTeam(piece) == "Red" else 1
		var dirs = [dir]
		if abs(sel.x-vec.x) == 1 and sel.y-vec.y == 1*dir and getPiece(vec): return true
		if sel.y in [1,6]: dirs.append(2*dir)
		if vec.x != sel.x: return false
		if sel.y-vec.y not in dirs: return false
		if getPiece(vec): return false
		if checkJumps(sel, vec): return false
		
	elif type == 'H':
		var d = abs(vec-sel)
		var d_arr = [d.x, d.y]
		d_arr.sort()
		if d_arr != [1,2]: return false
		
	elif type == 'T':
		var d:Vector2 = vec-sel
		if int(rad_to_deg(d.angle()))%90!=0 : return false
		if checkJumps(sel, vec): return false
		
	elif type == 'B':
		var d = abs(vec-sel)
		if d.x != d.y : return false
		if checkJumps(sel, vec): return false
		
	elif type == 'Q':
		var d:Vector2 = vec-sel
		if int(rad_to_deg(d.angle()))%45!=0 : return false
		if checkJumps(sel, vec): return false
		
	elif type == 'K':
		var t = abs(vec-sel)
		if t.x>1 or t.y>1 : return false
		
	return true
