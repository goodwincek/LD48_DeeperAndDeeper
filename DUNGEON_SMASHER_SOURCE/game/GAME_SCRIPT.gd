extends Node2D
#
# constants
const tileSize: float = 25.0
const mapWidth = 40
#
# scenes
const scene_hero = preload("res://HERO/HERO.tscn")
const scene_tile = preload("res://TILES/GroundTileBase.tscn")
const scene_pixel = preload("res://FX/pixel.tscn")
const scene_flash = preload("res://FX/flash.tscn")
const scene_streak = preload("res://FX/streak.tscn")
const scene_popup = preload("res://FX/textPopup.tscn")

# holders
onready var TILES = $TILE_HOLDER

var groundArray = []
var killCount = 0
var herodepth = 0
var depthMilestone = 100
var depthRamp = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	$MusicPlayer.play()
	print("game started " + self.get_path())
	
	#generate ground through loop
	spawn_chunk(20)
	   
		
	
	#spawn in hero
#	var h = scene_hero.instance()
#	h.position = Vector2(210, -400)
#	add_child(h)

func _process(_delta):
#	$UI/LABEL_KILLS.text = str(killCount)
	herodepth = pos_to_coordinates($Hero.position).y
	$UI/LABEL_DEPTH.text = "DEPTH: " + str(herodepth)
	$UI/LABEL_FPS.text = str(Engine.get_frames_per_second())
	
	if(herodepth >= depthMilestone):
		print("milestone")
		depthMilestone += depthRamp
		depthRamp += 100
		var pop = scene_popup.instance()
		$UI/TEXT_LOC.add_child(pop)
		pop.newMessage("YOU HAVE \nREACHED\n" + str(round(herodepth/100)*100)+"\nfeet!")
		playSound("milestone")
	
	#mute music
	if(Input.is_action_just_pressed("mute")):
		if($MusicPlayer.stream_paused == false):
			$MusicPlayer.stream_paused = true
		else:
			$MusicPlayer.stream_paused = false
	
	
	

	
	#ADD LAYERS AS YOU GO DEEPER
	if(herodepth>groundArray.size()-40):
		spawn_chunk(10)

#func _input(event):
#   # Mouse in viewport coordinates.
#	if event is InputEventMouseButton:
#
#		var m = get_global_mouse_position()
#		break_Bricks(m, 4)
#		var tile = findTile(m)
#		if(tile != null):
#			tile.die() 
			
func break_Bricks(center, radius):
	var snd = round(clamp(radius/2, 1, 4))
	playSound("explosion"+str(snd))
	flash(center+Vector2(0, (radius/2)*tileSize))
	var c = pos_to_coordinates(center)
	# checks if there is a tile below node with a base width
	for j in range(-radius,radius+1):
		for i in range(-radius,radius+1):
			if(abs(i)+abs(j)<=radius and abs(i)<radius and abs(j)<radius):
				var x = c.x+i
				var y = c.y+j
				if(x >= 0 and x<mapWidth and y>=0 and y<groundArray.size()):
					var tile = groundArray[y][x]
					tile.die()

# returns the tile at pos (x,y)
func findTile(pos):
	var c = pos_to_coordinates(pos)
	# check y first
	if(c.y >= 0 and c.y<groundArray.size()):
		if(c.x >= 0 and c.x < mapWidth):
			return groundArray[c.y][c.x]
			
	return null
	
func pos_to_coordinates(pos):
	var x = round((pos.x-tileSize/2)/tileSize)
	var y = round((pos.y-tileSize/2)/tileSize)
	return Vector2(x, y)

#spawn a chunk of ground (added to the bottom)
func spawn_chunk(depth):
	var startingIndex = groundArray.size()
	for y in range(startingIndex, startingIndex+depth):
		groundArray.append([])
		groundArray[y]=[]
		spawn_row(y)   
		

#spawn 1 row and append to the array
func spawn_row(depth):
	for x in range(mapWidth):
		groundArray[depth].append([])
		groundArray[depth][x] = spawn_tile(x,depth)  

func spawn_tile(x,y):
	var tile = scene_tile.instance()
	$TILE_HOLDER.add_child(tile)
	tile.position = Vector2(x*tileSize, y*tileSize)
	return(tile)

func hitTest(pos):
	var tile = findTile(pos)
	if(tile != null and tile.dead == false):
		tile.highlight() 
		return true
	else:
		return false

func explode(pos):
	var fx = scene_pixel.instance()
	$FX.add_child(fx)
	fx.position = pos
	
func streak(pos, scale):
	var fx = scene_streak.instance()
	$FX.add_child(fx)
	fx.position = pos
	fx.setMaxScale(rand_range(scale/2, scale))

func flash(pos):
	for _i in rand_range(23,100):
		var fx = scene_flash.instance()
		$FX.add_child(fx)
		fx.position = pos+Vector2(rand_range(-50,50), 0)

func playSound(name:String):
	$Sounds.get_node(name).play()


func _on_AudioStreamPlayer_finished():
	$MusicPlayer.play()
