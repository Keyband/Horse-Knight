#https://coolors.co/ffaa5f-0c2c45-574a68-d0805b-1b998b-e71d36-8dab7f-cfee9e

extends TileMap

# The heart of the entire code I think
enum Tiles {Empty, Player, King, Spikes, Tower, Bishop, Queen, Pawn}
const aKingMoves = [
	Vector2(0,-1),
	Vector2(1,-1),
	Vector2(1,0),
	Vector2(1,1),
	Vector2(0,1),
	Vector2(-1,1),
	Vector2(-1,0),
	Vector2(-1,-1),
]
var numberOfMoves=0
export(int) var maximumNumberOfMoves=5
var hasWon=false
const fDotMaxRadius=4
var grid=[]
var fDotRadius=4
var fSelectedDotRadius=4
var altProcessing=true
var playerWasInDangerLastTurn=false
var playerInDanger=false
var playerInDangerTwice=false
var dangerTiles=[]
const constDangerColor=Color('#E71D36')
var dangerColor=Color('#E71D36')
# Chess Knight moves
const moves=[
	Vector2(-1,2),
	Vector2(1,2),
	Vector2(2,1),
	Vector2(2,-1),
	Vector2(-2,1),
	Vector2(-2,-1),
	Vector2(1,-2),
	Vector2(-1,-2)
]
# For the _draw routine
const actorColors = [
	Color.black,
	Color.blue,
	Color.rebeccapurple,
	Color.red,
	Color.green,
	Color.purple,
	Color.yellow,
	Color.aliceblue
]
var bGameOver=false

export(Texture) var tilesTarget = load("res://resources/Sprites/TilesTargets_20x20.png")
const moveDrawFx=preload("res://scenes/moveDrawFx.tscn")
signal playerWon
signal enemiesMoved
func _ready():
	self.connect("playerWon",global,'fPlayerWon')
	# Creating the grid that will hold all the information
	# about the game state
	for i in range(8):
		grid.append([])
		for j in range(8):
			grid[i].append([])
			grid[i][j]=Tiles.Empty
	
	# According to the position of our sprite nodes, we can
	# add then to our grid
	for node in get_children():
		if not (node is Tween or node is CanvasLayer):
			var np=self.world_to_map(node.global_position)
			if node.is_in_group('Player'):
				grid[np.x][np.y]=Tiles.Player
			elif node.is_in_group('King'):
				grid[np.x][np.y]=Tiles.King
			elif node.is_in_group('Spikes'):
				grid[np.x][np.y]=Tiles.Spikes
			elif node.is_in_group('Tower'):
				grid[np.x][np.y]=Tiles.Tower
			elif node.is_in_group('Bishop'):
				grid[np.x][np.y]=Tiles.Bishop
			elif node.is_in_group('Queen'):
				grid[np.x][np.y]=Tiles.Queen
			elif node.is_in_group('Pawn'):
				grid[np.x][np.y]=Tiles.Pawn
	# Printing the initial grid, for debugging reasons
	print_debug('Grid:');print_debug(grid)
	
	#set_cellv(world_to_map($player.global_position),Tiles.Player)
	set_process(true)
	
var t=0
func _process(delta):
	if bGameOver and not $twnMove.is_active():
		var playerPosition=findTile(Tiles.Player)
		moveEnemies(playerPosition,playerPosition)
	if findTile(Tiles.Player)==Vector2(-1,-1):
		$twnMove.connect("tween_all_completed",self,'makePlayerDead')
	# Oscillate danger color
	t+=delta
	dangerColor.r = constDangerColor.r+0.3*sin(10*t)
	# Draw stuff
	update()
	# Some variables
	var tileWithMouse = world_to_map(get_global_mouse_position())
	var playerPosition = findTile(Tiles.Player)
	# Check if player won
	var won = true if findTile(Tiles.King)==Vector2(-1,-1) else false
	if won:
		hasWon=true
		if get_node("king").dead or true:
			emit_signal('playerWon')
			set_process(false)
	# Check if a move is legal
	var isAKnightMove = tileWithMouse-playerPosition in moves
	var mouseAtSpikes = getTileAt(tileWithMouse)==Tiles.Spikes
	# Change mouse cursor
	if isAKnightMove:
		var tileWithMouseIdx=getTileAt(tileWithMouse)
		if mouseAtSpikes: Input.set_default_cursor_shape(Input.CURSOR_FORBIDDEN)
		elif not $twnMove.is_active(): Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	else: Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	# Move player if possible
	if Input.is_action_just_pressed('ui_lmb') and isAKnightMove and not mouseAtSpikes and not bGameOver and not $twnMove.is_active():
		var oldPlayerPosition=playerPosition
		twnDotOut()
		createMoveDrawFx(self.map_to_world(tileWithMouse)+self.cell_size/2)
		moveObjToTile($player,tileWithMouse)
		if playerInDanger:
			moveEnemies(playerPosition,oldPlayerPosition)
		
						
	# Check if player is on a line of sight
	playerInDanger=false
	dangerTiles=[]
	for i in range(8):
		for j in range(8):
			var tile = getTileAt(Vector2(i,j))
			if tile==Tiles.Tower:
				if playerPosition.x==i:
					playerInDanger=true
					if playerPosition.y<j:
						for yy in range(playerPosition.y,j+1):
							dangerTiles.append(Vector2(i,yy))
					else:
						for yy in range(j,playerPosition.y+1):
							dangerTiles.append(Vector2(i,yy))
				if playerPosition.y==j:
					playerInDanger=true
					if playerPosition.x<i:
						for xx in range(playerPosition.x,i+1):
							dangerTiles.append(Vector2(xx,j))
					else:
						for xx in range(i,playerPosition.x+1):
							dangerTiles.append(Vector2(xx,j))
			if tile==Tiles.Bishop:
				var playerInSight=false
				for k in range(8):
					if not (i+k > 7 or i+k<0 or j+k > 7 or j+k<0):
						if getTileAt(Vector2(i+k,j+k))==Tiles.Player: playerInSight=true
					if not (i+k>7 or i+k<0  or j-k > 7 or j-k<0):
						if getTileAt(Vector2(i+k,j-k))==Tiles.Player: playerInSight=true
					if not (i-k > 7 or i-k<0 or j+k > 7 or j+k<0):
						if getTileAt(Vector2(i-k,j+k))==Tiles.Player: playerInSight=true
					if not (i-k>7 or i-k<0  or j-k > 7 or j-k<0):
						if getTileAt(Vector2(i-k,j-k))==Tiles.Player: playerInSight=true
				if playerInSight:
					playerInDanger=true
					if playerPosition.x<i:
						if playerPosition.y<j:#Topleft
							for k in range(i-playerPosition.x+1):
								dangerTiles.append(Vector2(i-k,j-k))
						else:#Bottomleft
							for k in range(i-playerPosition.x+1):
								dangerTiles.append(Vector2(i-k,j+k))
					else:
						if playerPosition.y<j:#Topright
							for k in range(playerPosition.x-i+1):
								dangerTiles.append(Vector2(i+k,j-k))
						else:#Bottomright
							for k in range(playerPosition.x-i+1):
								dangerTiles.append(Vector2(i+k,j+k))
			if tile==Tiles.Pawn:
				if playerPosition.y==(j+1) and (playerPosition.x==i+1 or playerPosition.x==i-1):
					playerInDanger=true
					dangerTiles.append(Vector2(i,j))
					dangerTiles.append(Vector2(i+1 if playerPosition.x==i+1 else i-1,j+1))
			if tile==Tiles.King:
				if playerPosition-Vector2(i,j) in aKingMoves:
					playerInDanger=true
					for kingTile in aKingMoves:
						dangerTiles.append(kingTile+Vector2(i,j))
			if tile==Tiles.Queen:
				if playerPosition.x==i:
					playerInDanger=true
					if playerPosition.y<j:
						for yy in range(playerPosition.y,j+1):
							dangerTiles.append(Vector2(i,yy))
					else:
						for yy in range(j,playerPosition.y+1):
							dangerTiles.append(Vector2(i,yy))
				if playerPosition.y==j:
					playerInDanger=true
					if playerPosition.x<i:
						for xx in range(playerPosition.x,i+1):
							dangerTiles.append(Vector2(xx,j))
					else:
						for xx in range(i,playerPosition.x+1):
							dangerTiles.append(Vector2(xx,j))
				else:
					var playerInSight=false
					for k in range(8):
						if not (i+k > 7 or i+k<0 or j+k > 7 or j+k<0):
							if getTileAt(Vector2(i+k,j+k))==Tiles.Player: playerInSight=true
						if not (i+k>7 or i+k<0  or j-k > 7 or j-k<0):
							if getTileAt(Vector2(i+k,j-k))==Tiles.Player: playerInSight=true
						if not (i-k > 7 or i-k<0 or j+k > 7 or j+k<0):
							if getTileAt(Vector2(i-k,j+k))==Tiles.Player: playerInSight=true
						if not (i-k>7 or i-k<0  or j-k > 7 or j-k<0):
							if getTileAt(Vector2(i-k,j-k))==Tiles.Player: playerInSight=true
					if playerInSight:
						playerInDanger=true
						if playerPosition.x<i:
							if playerPosition.y<j:#Topleft
								for k in range(i-playerPosition.x+1):
									dangerTiles.append(Vector2(i-k,j-k))
							else:#Bottomleft
								for k in range(i-playerPosition.x+1):
									dangerTiles.append(Vector2(i-k,j+k))
						else:
							if playerPosition.y<j:#Topright
								for k in range(playerPosition.x-i+1):
									dangerTiles.append(Vector2(i+k,j-k))
							else:#Bottomright
								for k in range(playerPosition.x-i+1):
									dangerTiles.append(Vector2(i+k,j+k))

func _draw():
	
	# Some variables
	var tileWithMouse = world_to_map(get_global_mouse_position())
	var playerPosition = findTile(Tiles.Player)
	# Draw red tile under player in case of danger
	if playerInDanger:
		for tile in dangerTiles:
			draw_rect(Rect2(self.map_to_world(tile),self.cell_size),dangerColor)
	# Draw grid and actors
	for i in range(0,8):
		for j in range(0,8):
			var cs=self.cell_size
			draw_line(cs*Vector2(i,j),cs*Vector2(i,j+1),Color('#544e68'),1.05)
			draw_line(cs*Vector2(i,j),cs*Vector2(i+1,j),Color('#544e68'),1.05)
			if getTileAt(Vector2(i,j))!=Tiles.Empty and OS.is_debug_build():
				drawTileAt(Vector2(i,j))
	# Draw possible moves
	if not bGameOver:
		for move in moves:
			var spriteRect2 = Rect2(Vector2(40,0) if self.world_to_map(get_global_mouse_position()) != (playerPosition+move) else Vector2(20,0),Vector2(20,20))
			draw_texture_rect_region(tilesTarget,
				Rect2(self.map_to_world(playerPosition+move),20*Vector2.ONE),
				spriteRect2)

# A bunch of helper functions:
func findTile(tile):
	for i in range(8):
		for j in range(8):
			if grid[i][j]==tile:
				return Vector2(i,j)
	return Vector2(-1,-1)
func tweenWithTaxiMetric(obj=Sprite,endPos=Vector2()):
	randomize()
	var movementDuration=rand_range(0.55,0.78)
	var rotationDuration=movementDuration*rand_range(1.1,1.3)
	if not obj.is_in_group('Bishop'):
		altProcessing=false
		#$twnMove.interpolate_property(obj, 'rotation', obj.rotation, -sign(obj.global_position.x-endPos.x)*PI/8,rotationDuration,Tween.TRANS_BACK,Tween.EASE_IN_OUT)
		$twnMove.interpolate_property(obj,'global_position:x',obj.global_position.x,endPos.x,movementDuration,Tween.TRANS_BACK,Tween.EASE_IN_OUT)
		$twnMove.start()
		$twn.interpolate_property(obj, 'rotation', obj.rotation, -sign(obj.global_position.x-endPos.x)*PI/8,rotationDuration,Tween.TRANS_BACK,Tween.EASE_IN_OUT)
		$twn.start()
		yield($twnMove,"tween_all_completed")
		$twnMove.interpolate_property(obj,'global_position:y',obj.global_position.y,endPos.y,movementDuration,Tween.TRANS_BACK,Tween.EASE_OUT)
		$twnMove.start()
		$twn.interpolate_property(obj, 'rotation', obj.rotation, 0,rotationDuration,Tween.TRANS_BACK,Tween.EASE_OUT)
		$twn.start()
		yield($twnMove,"tween_all_completed")
		altProcessing=true
		twnDotIn()
	else:
		altProcessing=false
		$twnMove.interpolate_property(obj, 'rotation', obj.rotation, -sign(obj.global_position.x-endPos.x)*PI/8,rotationDuration,Tween.TRANS_BACK,Tween.EASE_IN_OUT)
		$twnMove.interpolate_property(obj,'global_position',obj.global_position,endPos,movementDuration,Tween.TRANS_BACK,Tween.EASE_IN_OUT)
		$twnMove.start()
		yield($twnMove,"tween_all_completed")
		$twn.interpolate_property(obj, 'rotation', obj.rotation, 0,rotationDuration,Tween.TRANS_BACK,Tween.EASE_OUT)
		$twn.start()
		altProcessing=true
		twnDotIn()
func checkTileForNode(node):
	if node.is_in_group('Player'):
		return Tiles.Player
	elif node.is_in_group('King'):
		return Tiles.King
	elif node.is_in_group('Spikes'):
		return Tiles.Spikes
	elif node.is_in_group('Tower'):
		return Tiles.Tower
	elif node.is_in_group('Bishop'):
		return Tiles.Bishop
	elif node.is_in_group('King'):
		return Tiles.King
	elif node.is_in_group('Queen'):
		return Tiles.Queen
	elif node.is_in_group('Pawn'):
		return Tiles.Pawn
	else:
		return Tiles.Empty

func moveObjToTile(node=Node2D,to=Vector2()):
	var playerWasInDanger=playerInDanger
	var tile = checkTileForNode(node)
	var at = self.world_to_map(node.global_position)
	if node.is_in_group('Player'):
		numberOfMoves+=1

	tweenWithTaxiMetric(node,map_to_world(to))
	yield($twnDotRadius,"tween_all_completed")
	var tileAtDestination = getTileAt(to)
	if tileAtDestination!=Tiles.Empty and tileAtDestination!=Tiles.Player:
		for node in get_children():
			if (not (node is Tween or node is CanvasLayer)) and not node.is_in_group('Fx'):
				if to == self.world_to_map(node.global_position):
					$twnMove.connect("tween_all_completed",self,'killPiece',[node])
					#killPiece(node)

	grid[at.x][at.y]=Tiles.Empty
	grid[to.x][to.y]=tile
	if node.is_in_group('Player'):
		#numberOfMoves+=1
		if numberOfMoves>=maximumNumberOfMoves:
			$player.dead=true
		
		yield(self,'enemiesMoved')
		var playerIsInDanger=isPlayerInDanger(playerWasInDanger)
		print('Player was in danger: ', playerWasInDanger)
		print('Player is in danger now: ', playerIsInDanger)
		if playerWasInDanger and playerIsInDanger:
			$player.remove_from_group('Player')
			gameOver()
	else:
		emit_signal('enemiesMoved')
		
func killPiece(node):
	yield(get_tree().create_timer(0.2),'timeout')
	$twnMove.disconnect("tween_all_completed",self,'killPiece')
	node.dead=true
	node.offset=Vector2()
	node.centered=true
	node.global_position+=self.cell_size/2
func gameOver():
	bGameOver=true
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	
func isPlayerInDanger(was):
	var playerPosition=findTile(Tiles.Player)
	for i in range(8):
		for j in range(8):
			var tile = getTileAt(Vector2(i,j))
			if tile==Tiles.Tower:
				if playerPosition.x==i:
					return true
				if playerPosition.y==j:
					return true
			if tile==Tiles.Bishop:
				var playerInSight=false
				for k in range(8):
					if not (i+k > 7 or i+k<0 or j+k > 7 or j+k<0):
						if getTileAt(Vector2(i+k,j+k))==Tiles.Player: playerInSight=true
					if not (i+k>7 or i+k<0  or j-k > 7 or j-k<0):
						if getTileAt(Vector2(i+k,j-k))==Tiles.Player: playerInSight=true
					if not (i-k > 7 or i-k<0 or j+k > 7 or j+k<0):
						if getTileAt(Vector2(i-k,j+k))==Tiles.Player: playerInSight=true
					if not (i-k>7 or i-k<0  or j-k > 7 or j-k<0):
						if getTileAt(Vector2(i-k,j-k))==Tiles.Player: playerInSight=true
				if playerInSight:
					return true
			if tile==Tiles.Pawn:
				if playerPosition.y==(j+1) and (playerPosition.x==i+1 or playerPosition.x==i-1):
					return true
			if tile==Tiles.King:
				if playerPosition-Vector2(i,j) in aKingMoves:
					return true
			if tile==Tiles.Queen:
				if playerPosition.x==i:
					 return true
				if playerPosition.y==j:
					 return true
				else:
					var playerInSight=false
					for k in range(8):
						if not (i+k > 7 or i+k<0 or j+k > 7 or j+k<0):
							if getTileAt(Vector2(i+k,j+k))==Tiles.Player: playerInSight=true
						if not (i+k>7 or i+k<0  or j-k > 7 or j-k<0):
							if getTileAt(Vector2(i+k,j-k))==Tiles.Player: playerInSight=true
						if not (i-k > 7 or i-k<0 or j+k > 7 or j+k<0):
							if getTileAt(Vector2(i-k,j+k))==Tiles.Player: playerInSight=true
						if not (i-k>7 or i-k<0  or j-k > 7 or j-k<0):
							if getTileAt(Vector2(i-k,j-k))==Tiles.Player: playerInSight=true
					if playerInSight:
						return true
	return false
func getTileAt(at):
	at.x=int(clamp(at.x,0,7))
	at.y=int(clamp(at.y,0,7))
	return grid[at.x][at.y]
func drawTileAt(at):
	var tile=getTileAt(at)
	var tileColor=Color.black
	if tile==Tiles.Empty:pass
	else:tileColor=actorColors[tile]
	draw_circle(0.5*self.cell_size+map_to_world(at),fDotRadius,tileColor)
func twnDotIn():
	$twnDotRadius.interpolate_property(self,'fDotRadius',self.fDotRadius,self.fDotMaxRadius,0.4,Tween.TRANS_BACK,Tween.EASE_OUT)
	$twnDotRadius.start()
func twnDotOut():
	$twnDotRadius.interpolate_property(self,'fDotRadius',self.fDotRadius,0,0.25,Tween.TRANS_BACK,Tween.EASE_IN)
	$twnDotRadius.start()
func moveEnemies(playerPosition=Vector2(),oldPlayerPosition=Vector2()):
	for i in range(8):
		for j in range(8):
			var tile = getTileAt(Vector2(i,j))
			if tile==Tiles.Tower:
				if playerPosition.x==i or playerPosition.y==j:
					var movingPiece
					for node in get_children():
						if node.is_in_group('Tower') and self.world_to_map(node.global_position) == Vector2(i,j):
							movingPiece=node
					moveObjToTile(movingPiece,oldPlayerPosition)
					return
			elif tile==Tiles.Bishop:
				var playerInSight=false
				for k in range(8):
					if not (i+k > 7 or i+k<0 or j+k > 7 or j+k<0):
						if getTileAt(Vector2(i+k,j+k))==Tiles.Player: playerInSight=true
					if not (i+k>7 or i+k<0  or j-k > 7 or j-k<0):
						if getTileAt(Vector2(i+k,j-k))==Tiles.Player: playerInSight=true
					if not (i-k > 7 or i-k<0 or j+k > 7 or j+k<0):
						if getTileAt(Vector2(i-k,j+k))==Tiles.Player: playerInSight=true
					if not (i-k>7 or i-k<0  or j-k > 7 or j-k<0):
						if getTileAt(Vector2(i-k,j-k))==Tiles.Player: playerInSight=true
				if playerInSight:
					var movingPiece
					for node in get_children():
						if node.is_in_group('Bishop') and self.world_to_map(node.global_position) == Vector2(i,j):
							movingPiece=node
					moveObjToTile(movingPiece,oldPlayerPosition)
					return
			elif tile==Tiles.Pawn:
				if playerPosition.y==(j+1) and (playerPosition.x==i+1 or playerPosition.x==i-1):
					var movingPiece
					for node in get_children():
						if node.is_in_group('Pawn') and self.world_to_map(node.global_position) == Vector2(i,j):
							movingPiece=node
					moveObjToTile(movingPiece,oldPlayerPosition)
					return
			elif tile==Tiles.King:
				if playerInDanger:
					if playerPosition-Vector2(i,j) in aKingMoves:
						var movingPiece
						for node in get_children():
							if node.is_in_group('King') and self.world_to_map(node.global_position) == Vector2(i,j):
								movingPiece=node
						moveObjToTile(movingPiece,oldPlayerPosition)
						return
			elif tile==Tiles.Queen:
				if playerPosition.x==i or playerPosition.y==j:
					var movingPiece
					for node in get_children():
						if node.is_in_group('Queen') and self.world_to_map(node.global_position) == Vector2(i,j):
							movingPiece=node
					moveObjToTile(movingPiece,oldPlayerPosition)
					return
				else:
					var playerInSight=false
					for k in range(8):
						if not (i+k > 7 or i+k<0 or j+k > 7 or j+k<0):
							if getTileAt(Vector2(i+k,j+k))==Tiles.Player: playerInSight=true
						if not (i+k>7 or i+k<0  or j-k > 7 or j-k<0):
							if getTileAt(Vector2(i+k,j-k))==Tiles.Player: playerInSight=true
						if not (i-k > 7 or i-k<0 or j+k > 7 or j+k<0):
							if getTileAt(Vector2(i-k,j+k))==Tiles.Player: playerInSight=true
						if not (i-k>7 or i-k<0  or j-k > 7 or j-k<0):
							if getTileAt(Vector2(i-k,j-k))==Tiles.Player: playerInSight=true
					if playerInSight:
						var movingPiece
						for node in get_children():
							if node.is_in_group('Queen') and self.world_to_map(node.global_position) == Vector2(i,j):
								movingPiece=node
						moveObjToTile(movingPiece,oldPlayerPosition)
						return
func createMoveDrawFx(at):
	var i=moveDrawFx.instance()
	i.global_position=at
	add_child(i)
func makePlayerDead():
	$twnMove.disconnect("tween_all_completed",self,'makePlayerDead')
	yield(get_tree().create_timer(0.25),'timeout')
	if not $player.dead:
		$player.offset=Vector2()
		$player.centered=true
		$player.global_position+=self.cell_size/2
		$player.dead=true
