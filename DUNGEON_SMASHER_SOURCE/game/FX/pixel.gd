extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var angle = rand_range(0, 360)*PI/180
var speed = rand_range(0, 420)
var momentum = Vector2(cos(angle)*speed, sin(angle)*speed)
var rotSpeed = rand_range(0,10)

# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.set_wait_time(rand_range(0.25, 1))
	$Timer.start()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += momentum*delta
	momentum.x *= 1-0.9*delta
	momentum.y += 1200*delta
	var w = $Timer.time_left/$Timer.wait_time
	scale = Vector2(w,w)
	rotation_degrees += rotSpeed*delta


func _on_Timer_timeout():
	queue_free()
