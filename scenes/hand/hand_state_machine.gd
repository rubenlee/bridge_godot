class_name HandStateMachine
extends Node

@export var initial_state: HandState

var current_state: HandState
var states := {}

func init() -> void:
	for child in get_children():
		if child is HandState:
			states[child.state] = child
			child.transition_requested.connect(_on_transition_requested)
		if initial_state:
			initial_state.enter()
			current_state = initial_state

func on_think_action() -> void:
	if current_state:
		current_state.think_action()

func _on_transition_requested(from: HandState, to: HandState.State) -> void:
	if from != current_state:
		return
	var new_state: HandState = states[to]
	if not new_state:
		return
	if current_state:
		current_state.exit()
	new_state.enter()
	current_state = new_state
