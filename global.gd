extends Node
signal sPlayerDead
func _ready():
	OS.window_size*=3
	
func playerOnKing():
	print_debug("Eba!")

func playerDead():
	emit_signal("sPlayerDead")
