extends GridContainer

signal press(vec)

@onready var buttons = get_children()

func _ready():
	for i in range(len(buttons)):
		buttons[i].pressed.connect(pressed.bind(i))

func _process(delta):
	pass

func pressed(idx):
	press.emit(Vector2i(idx%8,idx/8))
	
