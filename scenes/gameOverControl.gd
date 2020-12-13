extends Control
const transitionLayer=preload("res://scenes/transitionLayer.tscn")
const clickSfx=preload("res://scenes/clickSfx.tscn")

func _ready():
	set_process(true)
	self.rect_global_position.y=-self.rect_size.y
	global.connect('sPlayerWon',self,'getInvisible')
	global.connect('sPlayerDead',self,'goIn')
	$marginContainer/marginContainer/gameOverPanel/marginContainer/vBoxContainer/button.connect("pressed",self,'resetStage')
func _process(delta):
	if Input.is_action_just_pressed('ui_reset'):
		resetStage()
func getInvisible():
	self.visible=false
func goIn():
	$twn.interpolate_property(self,'rect_global_position:y',self.rect_global_position.y,0,0.66,Tween.TRANS_QUINT,Tween.EASE_OUT)
	$twn.start()
func resetStage():
	global.add_child(clickSfx.instance())
	var i=transitionLayer.instance()
	i.fade='fadeOut'
	get_parent().get_parent().add_child(i)
	yield(i,"transitionDone")
	get_tree().reload_current_scene()
