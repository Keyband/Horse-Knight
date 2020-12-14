extends Node
signal sPlayerDead
signal sPlayerWon

var stagesPacifist = 0
var stagesLastMove = 0

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
	
func objectivesCheck(var moves, var asKilled):
	
	if moves == true: stagesLastMove += 1
	if asKilled == false: stagesPacifist += 1
	
	print("Stages Last move: " + str(stagesLastMove))		
	print("Stages Pacifist: "+ str(stagesPacifist))
	
