extends Node
export(PackedScene) var nextLevel=load("res://scenes/rootDebug.tscn")
const transitionLayer=preload("res://scenes/transitionLayer.tscn")
func _ready():
	var i=transitionLayer.instance()
	i.fade='fadeIn'
	add_child(i)
	yield(i,"transitionDone")
