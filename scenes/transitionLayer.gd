extends CanvasLayer
signal transitionDone
export(String, 'fadeOut', 'fadeIn') var fade='fadeOut'
const px = preload("res://scenes/px.tscn")
func _ready():
	if fade=='fadeOut':
		for i in range(9):
			for j in range(9):
				var k=px.instance()
				k.global_position=Vector2(i,j)*19
				add_child(k)
				$twn.interpolate_property(k,'scale',k.scale,Vector2.ONE*20,0.4,Tween.TRANS_QUART,Tween.EASE_OUT)
				$twn.interpolate_property(k,'rotation',k.rotation,PI,0.4,Tween.TRANS_QUART,Tween.EASE_OUT)
	elif fade=='fadeIn':
		for i in range(9):
			for j in range(9):
				var k=px.instance()
				k.global_position=Vector2(i,j)*19
				k.scale=Vector2.ONE*20
				add_child(k)
				$twn.interpolate_property(k,'scale',k.scale,Vector2(),0.4,Tween.TRANS_QUART,Tween.EASE_OUT)
				$twn.interpolate_property(k,'rotation',k.rotation,PI,0.4,Tween.TRANS_QUART,Tween.EASE_OUT)
	$twn.connect("tween_all_completed",self,'emitTransitionDone')
	$twn.start()

func emitTransitionDone():
	emit_signal("transitionDone")
	pass
