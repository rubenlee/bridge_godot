class_name Hand
extends HBoxContainer

signal turn_over(whom_ended : int)
@onready var positionInTable: Vector2
#@onready var hand_state_machine: HandStateMachine = $HandStateMachine as HandStateMachine

var cards_dict = {}
var playerInd : int
var mode: int

func _ready():
	var parentName : String = self.get_parent().name
	playerInd = parentName.substr(parentName.length() - 1).to_int()
	var root := get_tree().get_first_node_in_group("root") as Table
	match playerInd:
		1:
			positionInTable = Vector2(600,300)
			root.player1_turn.connect(start_turn)
		2:
			positionInTable = Vector2(520,230)
			root.player2_turn.connect(start_turn)
		3:
			positionInTable = Vector2(600,170)
			root.player3_turn.connect(start_turn)
		4:
			positionInTable = Vector2(680,230)	
			root.player4_turn.connect(start_turn)
	#hand_state_machine.init()
	for child in get_children():
		if child is CardUI:
			var card_ui := child as CardUI
			card_ui.reparent_requested.connect(_on_card_ui_reparent_requested)
			card_ui.card_played.connect(_on_card_played)
	
func _on_card_ui_reparent_requested(child: CardUI) -> void:
	child.reparent(self)
	
func reconnect_signals() -> void:
	for child in get_children():
		if not child is CardUI:
			continue
		var card_ui := child as CardUI
		if not card_ui.reparent_requested.is_connected(_on_card_ui_reparent_requested):
			card_ui.reparent_requested.connect(_on_card_ui_reparent_requested)
		if not card_ui.card_played.is_connected(_on_card_played):
			card_ui.card_played.connect(_on_card_played)

func add_card(newCard : CardUI) -> void:
	var position_in_hand = 0
	for child in get_children():
		if not child is CardUI:
			continue
		var card_ui := child as CardUI
		if card_ui.symbol < newCard.symbol:
			position_in_hand += 1
			continue
		elif card_ui.symbol == newCard.symbol:
			if card_ui.value < newCard.value:
				position_in_hand += 1
				continue
			else:
				break
		else:
			break
	if not cards_dict.has(newCard.symbol):
		cards_dict[newCard.symbol] = []
	cards_dict[newCard.symbol].append(newCard.value)
	self.add_child(newCard)
	self.move_child(newCard, position_in_hand)
		
func selectable_cards() -> void:
	var table_layer := get_tree().get_first_node_in_group("table")
	var symbol_to_look = 0
	var symbol_found = false
	if table_layer.get_child_count() > 0:
		var first_card = table_layer.get_child(0)
		symbol_to_look = first_card.symbol
	for child in get_children():
		if not child is CardUI:
			continue
		var card_ui = child as CardUI
		if symbol_to_look == 0:
			card_ui.color.visible = true
			symbol_found = true
		elif symbol_to_look == card_ui.symbol:
			card_ui.color.visible = true
			symbol_found = true
	if not symbol_found:
		for child in get_children():
			if not child is CardUI:
				continue
			var card_ui = child as CardUI
			card_ui.color.visible = true

func _on_card_played() -> void:
	for child in get_children():
		if not child is CardUI:
			continue
		var card_ui = child as CardUI
		card_ui.color.visible = false
	turn_over.emit(playerInd)
	
func start_turn():
	var child = self.get_child(0) as CardUI
	if child.card_visible:
		selectable_cards()
	else:
		var root := get_tree().get_first_node_in_group("root") as Table
		match root.symbolPreferred:
			0:
				no_trumph_thinking()
			_:
				child.card_clicked()
			#_on_card_played()
	
func no_trumph_thinking() -> void:
	var table_layer := get_tree().get_first_node_in_group("table")
	var symbol_used : int
	var value_used : int = 0
	if table_layer.get_child_count() > 0:
		var first_card = table_layer.get_child(0) as CardUI
		var array_values : Array = cards_dict[first_card.symbol]
		symbol_used = first_card.symbol
		if array_values.is_empty():
			value_used = 100
			for symbol in cards_dict:
				for value in cards_dict[symbol]:
					if value < value_used:
						value_used = value
						symbol_used = symbol
		else:
			for value in cards_dict[symbol_used]:
				if value > value_used:
					value_used = value
		
	else:
		for symbol in cards_dict:
			for value in cards_dict[symbol]:
				if value > value_used:
					value_used = value
					symbol_used = symbol
	var x = cards_dict[symbol_used].find(value_used)
	cards_dict[symbol_used].remove_at(x)
	for child in get_children():
		if not child is CardUI:
			continue
		var card_ui = child as CardUI
		if card_ui.value == value_used and card_ui.symbol == symbol_used:
			await child.card_clicked()
