class_name HandState
extends Node

enum State{BASE, DEAL, NOTRUMPH}

signal transition_requested(from: HandState, to:State)

@export var state: State

var cards_in_hand = []

func think_action() -> void:
	pass
