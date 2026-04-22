extends Node2D

var board = [
	[null,null,null,null,null,null,null,null,],
	[null,null,null,null,null,null,null,null,],
	[null,null,null,null,null,null,null,null,],
	[null,null,null,null,null,null,null,null,],
	[null,null,null,null,null,null,null,null,],
	[null,null,null,null,null,null,null,null,],
	[null,null,null,null,null,null,null,null,],
	[null,null,null,null,null,null,null,null,],
	]

var sel = null
var tar = null
var turn = "Blue"
var finished = false
var toUpgrade = false

func _ready():
	$"../Buttons/GridContainer".press.connect(press)
	$"../Buttons/Upgrade".press.connect(upgrade)
	var red = $Red.get_children()
	var blue = $Blue.get_children()
	for i in range(8):
		for j in [[0,8,red],[1,0,red],[6,0,blue],[7,8,blue]]:
			board[i][j[0]] = j[2][i+j[1]]

func opposite(color):
	return {"Blue":"Red","Red":"Blue"}[color]

func getTeam(piece):
	return piece.get_parent().name

func getPiece(vec):
	return board[vec.x][vec.y]

func setPiece(vec,val):
	board[vec.x][vec.y] = val

func press(vec):
	if finished: return
	if toUpgrade: return
	if sel != null:
		move(vec)
	else:
		select(vec)
	moveSelection(vec)

func checkJumps(vec):
	var diff = vec - sel
	var step = Vector2i(sign(diff.x), sign(diff.y))
	var current = sel + step
	while current != vec:
		if getPiece(current) != null:
			return true
		current += step
	return false

func checkMove(vec):
	var piece = getPiece(sel)
	var type = piece.name.left(1)
	if type == 'P':
		var dir = {"Red":-1,"Blue":1}[getTeam(piece)]
		var dirs = [dir]
		if abs(sel.x-vec.x) == 1 and sel.y-vec.y == 1*dir and getPiece(vec): return true
		if sel.y in [1,6]: dirs.append(2*dir)
		if vec.x != sel.x: return false
		if sel.y-vec.y not in dirs: return false
		if getPiece(vec): return false
		if checkJumps(vec): return false
		if vec.y in [0,7]:
			toUpgrade = getPiece(sel)
			$"../Buttons/Anim".play("Open")
	if type == 'H':
		var d = abs(vec-sel)
		d = [d.x,d.y]
		d.sort()
		if d != [1,2]: return false
	if type == 'T':
		var d:Vector2 = vec-sel
		if int(rad_to_deg(d.angle()))%90!=0 : return false
		if checkJumps(vec): return false
	if type == 'B':
		var d = abs(vec-sel)
		if d.x != d.y : return false
		if checkJumps(vec): return false
	if type == 'Q':
		var d:Vector2 = vec-sel
		if int(rad_to_deg(d.angle()))%45!=0 : return false
		if checkJumps(vec): return false
	if type == 'K':
		var t = abs(vec-sel)
		if t.x>1 or t.y>1 : return false
	return true

func move(vec):
	var target = getPiece(vec)
	if target and getTeam(target) == turn:
		sel = null
		return
	if not checkMove(vec):
		sel = null
		return
	if target:
		tar = vec
		$"../RPG".start(getPiece(sel),getPiece(vec),turn)
		$"../Sound".playSound("battle")
		return
	var piece = board[sel.x][sel.y]
	var startPos = sel*16+Vector2i(8,8)
	var endPos = Vector2i(8,8) + vec*16
	$T_Move.startMove(piece,startPos,endPos)
	$"../Sound".playSound("move")
	setPiece(vec,piece)
	setPiece(sel, null)
	changeTurn()

func changeTurn():
	turn = opposite(turn)
	$"../Turn".material.set_shader_parameter("idx",["Blue","Red"].find(turn))
	sel = null

func capture(can):
	if not can:
		changeTurn()
		moveSelection(tar)
		$"../Sound".playSound("shield")
		return
	$"../Sound".playSound("destroy")
	getPiece(tar).queue_free()
	if getPiece(tar).name.left(1) == 'K':
		$"../Win/Anim".play(turn)
		$"../CanvasLayer/Anim".play("Out")
		$"../Sound".playSound("win")
		$"../Sound/music".stop()
		finished = true
	
	var piece = board[sel.x][sel.y]
	var startPos = sel*16+Vector2i(8,8)
	var endPos = Vector2i(8,8) + tar*16
	$T_Move.startMove(piece,startPos,endPos)
	$"../Sound".playSound("move")
	setPiece(tar,piece)
	setPiece(sel, null)
	changeTurn()
	moveSelection(tar)

func select(vec):
	var piece = board[vec.x][vec.y]
	if piece == null or getTeam(piece)!=turn:
		sel = null
		return
	sel = vec

func moveSelection(vec):
	if sel != null:
		$"../Selector".position = Vector2i(8,8) + sel*16
		$"../Sound".playSound("select")
	$"../Selector".visible = sel != null

func reset():
	$"../Turn".material.set_shader_parameter("idx",0)
	get_tree().change_scene_to_file("res://World/board.tscn")

func upgrade(op):
	if not toUpgrade: return
	toUpgrade.play(op)
	toUpgrade.name = op + toUpgrade.name.substr(1)
	toUpgrade = null
	$"../Buttons/Anim".play_backwards("Open")

func _process(delta):
	pass
