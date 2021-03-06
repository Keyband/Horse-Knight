extends Sprite
signal sPlayerDead
var dead=false
var t=0
var vVelocity = Vector2(30,-80)
var aVelocity = 20
var gravity = 165
var initialY=-1
func _ready():
	randomize()
	set_process(true)
	self.connect("sPlayerDead",global,'playerDead')
func _process(delta):
	if dead:
		if initialY==-1:
			initialY=self.global_position.y
		else:
			if self.global_position.y>initialY:
				emit_signal('sPlayerDead')
		var deltaAccel=1.33
		self.rotation+=aVelocity*delta*deltaAccel
		self.global_position.x+=vVelocity.x*delta*deltaAccel
		self.global_position.y+=vVelocity.y*delta*deltaAccel
		vVelocity.y+=gravity*delta*deltaAccel
#		if self.global_position.y > OS.window_size.y:
#			emit_signal('sPlayerDead')
