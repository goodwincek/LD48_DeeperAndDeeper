extends Node2D
class_name GroundTileBase

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var dead = false


onready var _root = get_tree().root.get_node("GAME")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func highlight():
	$Timer_reset.start()
	$Sprite.modulate = Color(1,0,0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func die():
	if(dead == false):
		_root.explode(self.position)
		dead = true
		self.hide()

func _on_Timer_reset_timeout():
	$Sprite.modulate = Color(1,1,1)
