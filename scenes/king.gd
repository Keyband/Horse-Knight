extends Sprite

func _ready():pass
func die():
	$area2D/collisionShape2D.disabled=true
	return
	var twnTime=rand_range(0.5,0.8)
	$twnDead.interpolate_property(self,"global_position:x",self.global_position.x,self.global_position.x+32*(2+randi()%5),twnTime,Tween.TRANS_LINEAR,Tween.EASE_IN)
	$twnDead.interpolate_property(self,'global_position:y',self.global_position.y,self.global_position.y+320,twnTime,Tween.TRANS_QUAD,Tween.EASE_IN)
	$twnDead.start()
