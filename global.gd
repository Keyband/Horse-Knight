extends Node
signal sPlayerDead
signal sPlayerWon

const music = preload("res://scenes/music.tscn")
func _ready():
	OS.window_size*=4
func playMusic():
	var i=music.instance()
	add_child(i)
func playerOnKing():
	print_debug("Eba!")

func playerDead():
	emit_signal("sPlayerDead")
func fPlayerWon():
	emit_signal('sPlayerWon')
