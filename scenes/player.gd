extends Sprite
signal onKing
func _ready():
	self.connect("onKing",global,'playerOnKing')
	$area2D.connect("area_entered",self,'checkAreaCollision')
func checkAreaCollision(area=Area2D):
	if area.is_in_group('King'):
		emit_signal('onKing')
		area.get_parent().die()
