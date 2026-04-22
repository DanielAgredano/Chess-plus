extends Node2D

@export var list:Array[String]

signal press(op)

@onready var buttons = get_children()

func _ready():
	for i in range(len(buttons)):
		buttons[i].pressed.connect(pressed.bind(i))

func pressed(idx):
	press.emit(list[idx])
