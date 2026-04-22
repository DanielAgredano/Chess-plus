extends Node2D

@export var hp = 1.0

func _ready():
	pass

func _process(delta):
	pass

func update(per):
	hp = per
	$Fill.size.x = 60.0*hp
