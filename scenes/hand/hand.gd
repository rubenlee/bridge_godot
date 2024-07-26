class_name Hand
extends HBoxContainer

signal turn_over(whom_ended : int)
signal bidding_over(whom_ended : int, bid_dealt : String)
@onready var positionInTable: Vector2
@onready var positionToMoveToTable : Vector2

var cards_dict := {}
var playerInd : int
var honor_points := 0
var distribution_points := 0
var balanced := false
var regular := false

func _ready():
	var parentName : String = self.get_parent().name
	for child in get_children():
		if child is CardUI:
			var card_ui := child as CardUI
			card_ui.reparent_requested.connect(_on_card_ui_reparent_requested)
			card_ui.card_played.connect(_on_card_played)

func highlight_card(value : int, symbol : int) -> void:
	for child in get_children():
		if not child is CardUI:
			continue
		var card_ui = child as CardUI
		if card_ui.value == value and card_ui.symbol == symbol:
			card_ui.color.color = Color.YELLOW
			card_ui.color_2.color = Color.YELLOW

func _on_card_ui_reparent_requested(child: CardUI) -> void:
	child.reparent(self)

func setPlayerInd(player : int):
	self.playerInd = player
	var root := get_tree().get_first_node_in_group("root") as Table
	var parentName : String = self.get_parent().name
	match playerInd:
		1:
			positionInTable = Vector2(600,300)
			root.player1_turn.connect(start_turn)
		2:
			positionInTable = Vector2(520,230)
			root.player2_turn.connect(start_turn)
			positionToMoveToTable = Vector2(-100,275)
		3:
			positionInTable = Vector2(600,170)
			root.player3_turn.connect(start_turn)
		4:
			positionInTable = Vector2(680,230)	
			positionToMoveToTable = Vector2(1380,275)
			root.player4_turn.connect(start_turn)

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
	if newCard.get_parent() == null:
		self.add_child(newCard)
	else:
		newCard.reparent(self)
	if newCard.value > 10:
		honor_points += newCard.value - 10
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
			if playerInd != 3:
				card_ui.color.visible = true
			else:
				card_ui.color_2.visible = true
			symbol_found = true
		elif symbol_to_look == card_ui.symbol:
			if playerInd != 3:
				card_ui.color.visible = true
			else:
				card_ui.color_2.visible = true
			symbol_found = true
	if not symbol_found:
		for child in get_children():
			if not child is CardUI:
				continue
			var card_ui = child as CardUI
			if playerInd != 3:
				card_ui.color.visible = true
			else:
				card_ui.color_2.visible = true

func disable_visible_for_cards() -> void:
	for child in get_children():
		if not child is CardUI:
			continue
		var card_ui = child as CardUI
		if playerInd != 3:
			card_ui.color.visible = false
			card_ui.color.color = Color.RED
		else:
			card_ui.color_2.visible = false
			card_ui.color_2.color = Color.RED

func _on_card_played() -> void:
	turn_over.emit(playerInd)
	
func start_turn():
	var child = self.get_child(0) as CardUI
	var npc_controlled = false
	var root := get_tree().get_first_node_in_group("root") as Table
	if not child.card_visible:
		npc_controlled = true
	if not npc_controlled:
		if not root.bidding_state:
			selectable_cards()
	else:
		match root.symbolPreferred:
			_:
				no_trumph_thinking()


func bidding_thinking(bid_value : int, symbol_value : int, player_voted : int) -> void:
	var bid_result = "pass"
	var par = player_voted % 2
	if bid_value == 0:
		if honor_points >= 15 and honor_points <= 17 and balanced:
			bid_result = "1NT"
		elif honor_points >= 20 and honor_points <= 22 and balanced:
			bid_result = "2NT"
		elif honor_points > 24 and balanced:
			bid_result = "3NT"
		elif honor_points > 11 and honor_points < 21:
			for i in cards_dict:
				if cards_dict[i].size() >= 5:
					bid_result = "1" + get_string_symbol(i)
	else:
		match bid_value:
			1:
				match symbol_value:
					5:
						if par == playerInd % 2:
							if honor_points > 9:
								bid_result = "3NT"
							elif honor_points > 7:
								bid_result = "2NT"
					_:
						if par == playerInd % 2:
							if cards_dict[symbol_value - 1].size() > 2:
								if honor_points + distribution_points >= 6 and honor_points + distribution_points <= 10:
									bid_result = "2" + get_string_symbol(symbol_value)
								elif honor_points + distribution_points >= 11 and honor_points + distribution_points <= 12:
									bid_result = "3" + get_string_symbol(symbol_value)
								elif honor_points + distribution_points >= 11 and honor_points + distribution_points <= 12:
									bid_result = "4" + get_string_symbol(symbol_value)
	bidding_over.emit(playerInd, bid_result)	

func get_string_symbol(value : int) -> String:
	var result := ""
	match value:
		1:
			result  = "C"
		2:
			result  = "D"
		3:
			result  = "H"
		4:
			result  = "S"
	return result

func get_best_card_on_table_no_trumph() -> CardUI:
	var table_layer := get_tree().get_first_node_in_group("table")
	var result : CardUI = table_layer.get_child(0)
	for card : CardUI in get_tree().get_first_node_in_group("table").get_children():
		if result == card:
			continue
		if card.symbol == result.symbol:
			if card.value > result.value:
				result = card
	return result
	
func no_trumph_thinking() -> void:
	var table_layer := get_tree().get_first_node_in_group("table")
	var root := get_tree().get_first_node_in_group("root") as Table
	var symbol_used : int
	var value_used : int = 0
	var cards_played = table_layer.get_child_count()
	var best_card : CardUI
	if cards_played > 0:
		var first_card = table_layer.get_child(0) as CardUI
		var array_values : Array = []
		best_card = get_best_card_on_table_no_trumph()
		symbol_used = first_card.symbol
		if cards_dict.has(symbol_used):
			array_values = cards_dict[symbol_used]
		if array_values.is_empty():
			value_used = 100
			if symbol_used != root.symbolPreferred and cards_dict.has(root.symbolPreferred):
				symbol_used = root.symbolPreferred
				for value in cards_dict[symbol_used]:
					if value < value_used:
						value_used = value
			else:
				for symbol in cards_dict:
					for value in cards_dict[symbol]:
						if value < value_used:
							value_used = value
							symbol_used = symbol
		else:
			
			for value in cards_dict[symbol_used]:	
				if value > value_used:
						value_used = value
			if best_card.player % 2 == playerInd % 2 and value_used < best_card.value:
				value_used = 100
				for value in cards_dict[symbol_used]:	
					if value < value_used:
							value_used = value
	else:
		for symbol in cards_dict:
			for value in cards_dict[symbol]:
				if value > value_used:
					value_used = value
					symbol_used = symbol
	var x = cards_dict[symbol_used].find(value_used)
	cards_dict[symbol_used].remove_at(x)
	if cards_dict[symbol_used].is_empty():
		cards_dict.erase(symbol_used)
	for child in get_children():
		if not child is CardUI:
			continue
		var card_ui = child as CardUI
		if card_ui.value == value_used and card_ui.symbol == symbol_used:
			await child.card_clicked()
