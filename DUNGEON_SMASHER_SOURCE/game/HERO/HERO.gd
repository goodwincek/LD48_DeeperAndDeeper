extends Node2D

# constants
const movespeed = 500

const baseWidth = 12.5
const baseHeight = 18

const grav_value = 2323
const slam_gravity = 12000 

# vars
var momentum = Vector2.ZERO
var max_momentum = 1200
var cameraShakeVector = Vector2.ZERO
var cameraShakeValue = 0

# STATE BOOLS
var jumping = false
var slam_attack_ready = true
var slam_Aftershock = false
var slamming = false
var wallSliding = false
var grounded = false
var dir = 0

var currentFrame = 0

# scenes / etc
onready var _root = get_tree().root.get_node("GAME")
onready var leftBound = 0
onready var rightBound = _root.tileSize*_root.mapWidth

enum States {IDLE, RUNNING, JUMPING, SLAMMING}
var _state:int = States.IDLE

var print_msg

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

#
#
# PROCESS - MAIN LOGIC
#
#
func _process(delta):
	#
	# MOVEMENT 
	#
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
#	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	if(input_vector.x != 0 and input_vector.x != dir):
		dir = sign(input_vector.x)
	
	# friction when not pressing
	if(input_vector.x == 0):
		momentum.x *= 1 - 0.9*delta*4
		
	# make reversing direction more responsive:
	elif(momentum.x/input_vector.x <0 and grounded):
		momentum.x *= 1 - 0.9*delta*8
	
	momentum.x += input_vector.x * movespeed * delta;
	momentum.x = clamp(momentum.x, -max_momentum, max_momentum)
	
	# checks walls + WALL SLIDING
	var xtarget = momentum.x*delta + sign(momentum.x)*baseWidth
	if(checkWalls(xtarget)):
		if not(slamming):
			$wallJumpTimer.start()
			wallSliding = true
			jumping = false
		momentum.x *= 0.1
		momentum.y *= 0.25
		while(checkWalls(xtarget)):
			position.x -= sign(momentum.x)*delta
	else:
		#disables wall slide if you move off the wall
		if not(checkWalls(sign(momentum.x)*baseWidth*1.5)):
			wallSliding = false
		if wallSliding:
			momentum.y *= 0.5
	position.x += momentum.x*delta
	
	# CANNOT JUMP DURING SLAM
	if not(slamming):
		#
		# Y-MOTION
		#debug hold up to float
		var debugFly = Input.is_action_pressed("ui_up")
		if(debugFly):
			momentum.y = -2300
			slam_attack_ready = true
			jumping = true
		#
		# JUMPING
		var j = Input.is_action_just_pressed("action")
		if(j and jumping == false):
			jumping = true
			slam_attack_ready = true
			
			if(wallSliding and grounded == false):
				momentum.x = -sign(momentum.x)*(600+400*abs(momentum.x))
				jump(1200)
			else:
				jump(896)
		
		var j_release = Input.is_action_just_released("action")
		if(j_release):
			momentum.y *= 0.5
		
		var down_button = Input.is_action_just_pressed("ui_down")
		if(down_button and slam_attack_ready):
			slamAttack()
		
		if(Input.is_action_pressed("ui_down") and slam_Aftershock):
			aftershockAttack()
		else:
			slam_Aftershock = false
		
		
		var _j2 = Input.is_action_just_released("action")
	
	
	
#	position.y += input_vector.y * movespeed * delta;
	gravity(grav_value, delta)
	if(slamming):
		gravity(slam_gravity, delta)
	
	
	# MORE INCREMENTS FASTER YOU ARE GOING
	var yinc = round(abs(momentum.y)*delta/12)
	yinc = clamp(yinc, 1, 10)
	for _i in range(yinc):
		position.y += (momentum.y*delta)/yinc
		# handle hitting head before anything else
		if(momentum.y<0):
			var hitHead = false
			while(checkCeiling()):
				hitHead = true
				position.y+=0.1
			if(hitHead):
				print("hit head")
				momentum.y = 25
		# CHECK IF YOU HIT GROUND // IF SLAMMING, DESTROY
		else:
			grounded = false
			slam_attack_ready = true
			while(checkGround()):
				slam_attack_ready = false
				grounded = true
				if(slamming):
					destroyAttack(2+round(momentum.y/2000))
					slam_Aftershock = true
				groundReset()
				position -= Vector2(0, 0.1)
				momentum.y = min(momentum.y, 420)
		#
		#
		#
	
	# CAMERA STUFF
	var z = lerp(0.69, 2, (momentum.y-420)/4000)
	z = clamp(z, 0.69, 2)

#	$Camera2D.zoom += (Vector2(z,z)-$Camera2D.zoom)/8
	var zoom_amt = 1+(position.y/10000)
	zoom_amt = clamp(zoom_amt, 1, 2)
	$Camera2D.zoom = Vector2(zoom_amt, zoom_amt)
#	if(Input.is_action_just_released("ui_page_down")):
#		$Camera2D.zoom += Vector2(zoom_amt, zoom_amt)
#	if(Input.is_action_just_released("ui_page_up")):
#		$Camera2D.zoom -= Vector2(zoom_amt, zoom_amt)
	var a = randf()*360
	cameraShakeVector = Vector2(cos(a)*cameraShakeValue/12, sin(a)*cameraShakeValue)
	$Camera2D.offset = cameraShakeVector*($cameraShakeTimer.time_left/$cameraShakeTimer.wait_time)
	
	# ANIMATION
	if(slamming or slam_Aftershock):
		currentFrame = 1
	elif(jumping):
		currentFrame = 2
	else:
		currentFrame = 0
	$Sprite.frame = currentFrame
	
	if(abs(momentum.y)>500):
		_root.streak(position, abs(momentum.y)/100)
	

func slamAttack():
	momentum.y = 420
	slamming = true

func aftershockAttack():
	if($aftershockTimer.is_stopped()):
		$aftershockTimer.start()
	
	
func destroyAttack(r):
	cameraShake(6+6*r, 0.5)
	_root.break_Bricks(position, r*2)


func checkWalls(xoffset):
	#going off the edge
	if(position.x+xoffset<leftBound or position.x+xoffset>rightBound):
		while(position.x<leftBound):
			position.x += 0.1
		while(position.x>rightBound):
			position.x -= 0.1
		return true
	else:
		return hitTest(xoffset, baseHeight, 1, 1, -2, -2)

func jump(speed):
	momentum.y = -speed

func gravity(g, delta):
	momentum.y += g*delta
	pass

func checkCeiling():
	return hitTest(baseWidth-5, baseHeight+5, -1, 1, -2, -2, true)

func checkGround():
	return hitTest(baseWidth, 0, -1, 1, 0, 0, true)

func hitTest(width, height, x, x2, y, y2, msg=false):
	for i in range(x, x2+1):
		for j in range(y, y2+1):
			var hit = _root.hitTest(self.position+Vector2(width*i, height*j))
			if(hit):
				return true
	return false

func groundReset():
	# resets a number of variables for jump/attack
	jumping = false
	slam_attack_ready = false
	slamming = false
	wallSliding = false
	grounded = true

func cameraShake(amt, duration):
	cameraShakeValue = amt
	$cameraShakeTimer.wait_time = duration
	$cameraShakeTimer.start()

func _on_PRINTER_timeout():
#	print(print_msg)
	pass

func _on_cameraShakeTimer_timeout():
	cameraShakeValue = 0


func _on_wallJumpTimer_timeout():
	wallSliding = false
	jumping = true
	slam_attack_ready = true


func _on_aftershockTimer_timeout():
	if(slam_Aftershock):
		destroyAttack(4)
