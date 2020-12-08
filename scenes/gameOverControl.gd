extends Control

func _ready():
	self.rect_global_position.y=-self.rect_size.y
	global.connect('sPlayerDead',self,'goIn')
	$marginContainer/marginContainer/gameOverPanel/marginContainer/vBoxContainer/button.connect("pressed",self,'nextStage')
func goIn():
	$twn.interpolate_property(self,'rect_global_position:y',self.rect_global_position.y,0,0.66,Tween.TRANS_QUINT,Tween.EASE_OUT)
	$twn.start()
func nextStage():
	get_tree().reload_current_scene()
