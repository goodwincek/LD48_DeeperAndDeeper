extends Node
class_name HeroMachine

signal transitioned(state_name)

export var initial_state := NodePath()

onready var state:State = get_node(initial_state)

func _ready():
	yield(owner, "ready")
	
	print(get_children())
	for child in get_children():
		child.state_machine = self
#	state.enter()
	
func _unhandled_input(event: InputEvent) -> void:
	state.handle_input(event)
	
func _process(delta: float) -> void:
	state.update(delta)

func transition_to(target_state_name: String, msg: Dictionary = {}) -> void:
	if not has_node(target_state_name):
		return

	state.exit()
	state = get_node(target_state_name)
	state.enter(msg)
	emit_signal("transitioned", state.name)
