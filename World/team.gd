extends Node2D

@onready var pieces = get_children()

func _ready():
	for piece in pieces:
		piece.play(piece.name.left(1))

func _process(delta):
	pass
