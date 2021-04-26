extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var angle = rand_range(0, 360)*PI/180
var speed = rand_range(0, 200)
var momentum = Vector2(cos(angle)*speed, 400+sin(angle)*speed)
var maxSize = rand_range(1,4)

func _init():
	randomize()

# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.set_wait_time(rand_range(0.25, 1))
	$Timer.start()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += momentum*delta
	momentum.x *= 1-0.9*delta
	momentum.y -= 400*delta
	var w = $Timer.time_left/$Timer.wait_time
	var s = 0.25+(1-w)*maxSize
	scale = Vector2(s, s)
	modulate.a = w


func _on_Timer_timeout():
	queue_free()
