extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var maxScale = 1
# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.set_wait_time(rand_range(0.25, 1))
	$Timer.start()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	updateScale()

func updateScale():
	var w = ($Timer.time_left/$Timer.wait_time)*maxScale
	scale = Vector2(w,w)

func setMaxScale(s):
	maxScale = s
	updateScale()
	
	
func _on_Timer_timeout():
	queue_free()
