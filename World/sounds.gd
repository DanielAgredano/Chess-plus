extends Node

@onready var sounds = {
	"move": $move,
	"destroy": $destroy,
	"hit": $hit,
	"special": $special,
	"crit": $crit,
	"shield": $shield,
	"select": $select,
	"battle": $battle,
	"win": $win,
}

func playSound(_name):
	sounds[_name].play()
