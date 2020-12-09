extends Node
const transitionLayer=preload("res://scenes/transitionLayer.tscn")
func _ready():
	var i=transitionLayer.instance()
	i.fade='fadeIn'
	get_parent().add_child(i)
	yield(i,"transitionDone")
