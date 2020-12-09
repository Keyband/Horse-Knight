extends Control
const transitionLayer=preload("res://scenes/transitionLayer.tscn")
func _ready():
	self.rect_global_position.y=-self.rect_size.y
	global.connect('sPlayerWon',self,'goIn')
	$marginContainer/marginContainer/gameOverPanel/marginContainer/vBoxContainer/button.connect("pressed",self,'nextStage')
func goIn():
	yield(get_tree().create_timer(1.0),'timeout')
	$twn.interpolate_property(self,'rect_global_position:y',self.rect_global_position.y,0,0.66,Tween.TRANS_QUINT,Tween.EASE_OUT)
	$twn.start()
func nextStage():
	var i=transitionLayer.instance()
	i.fade='fadeOut'
	get_parent().get_parent().add_child(i)
	yield(i,"transitionDone")
	get_tree().change_scene_to(get_parent().get_parent().nextLevel)
