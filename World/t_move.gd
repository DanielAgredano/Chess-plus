extends Timer

var piece = null
var begin = null
var end = null

func _ready():
	pass

func _process(delta):
	if not piece: return
	var percent = (1-time_left/wait_time)
	piece.position = Vector2(begin) + (end - begin) * percent

func startMove(_piece,_begin,_end):
	piece = _piece
	begin = _begin
	end = _end
	start()
