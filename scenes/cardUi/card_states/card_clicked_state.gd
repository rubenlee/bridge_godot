extends CardState

func enter() -> void:
	pass
	
func on_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and card_ui.color.visible:
		card_ui.card_clicked()
		transition_requested.emit(self, CardState.State.BASE)
