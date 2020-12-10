extends Node
export(PackedScene) var nextLevel=load("res://scenes/rootDebug.tscn")
const transitionLayer=preload("res://scenes/transitionLayer.tscn")
func _ready():
	var i=transitionLayer.instance()
	i.fade='fadeIn'
	add_child(i)
	yield(i,"transitionDone")
	if OS.is_debug_build():
		set_process(true)
func _process(delta):
	if Input.is_action_just_pressed('ui_debug') and OS.is_debug_build():
		$controLayer/stageFinishedControl.nextStage()
		set_process(false)
	
