class_name Hand
extends HBoxContainer

@onready var positionInTable: Vector2

func _ready():
	var parentName : String = self.get_parent().name
	var playerInd : int = parentName.substr(parentName.length() - 1).to_int()
	match playerInd:
		1:
			positionInTable = Vector2(600,300)
		2:
			positionInTable = Vector2(520,230)
		3:
			positionInTable = Vector2(600,170)
		4:
			positionInTable = Vector2(680,230)	
	for child in get_children():
		var card_ui := child as CardUI
		card_ui.reparent_requested.connect(_on_card_ui_reparent_requested)
	
func _on_card_ui_reparent_requested(child: CardUI) -> void:
	child.reparent(self)
	
func reconnect_signals() -> void:
	for child in get_children():
		var card_ui := child as CardUI
		if not card_ui.reparent_requested.is_connected(_on_card_ui_reparent_requested):
			card_ui.reparent_requested.connect(_on_card_ui_reparent_requested)

func add_card(newCard : CardUI) -> void:
	var position = 0
	for child in get_children():
		var card_ui := child as CardUI
		if card_ui.symbol < newCard.symbol:
			position += 1
			continue
		elif card_ui.symbol == newCard.symbol:
			if card_ui.value < newCard.value:
				position += 1
				continue
			else:
				break
		else:
			break
	self.add_child(newCard)
	self.move_child(newCard, position)
	newCard.color.visible = newCard.card_visible
		
