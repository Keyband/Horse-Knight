extends Node
signal sPlayerDead
signal sPlayerWon
func _ready():
	OS.window_size*=3
	
func playerOnKing():
	print_debug("Eba!")

func playerDead():
	emit_signal("sPlayerDead")
func fPlayerWon():
	emit_signal('sPlayerWon')
