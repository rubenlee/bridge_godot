class_name Table
extends Node2D

@onready var normalCard: PackedScene = preload("res://scenes/cardUi/card_ui.tscn")
@onready var npcCard: PackedScene = preload("res://scenes/cardUi/card_ui_npc.tscn")

enum NOTRUMPHHANDS {BALANCED, ONESEMIFAIL, UNBALANCED}
signal player1_turn()
signal player2_turn()
signal player3_turn()
signal player4_turn()

var cards = ['314','114','214','414',
			 '302','102','202','402',
			 '303','103','203','403',
			 '304','104','204','404',
			 '305','105','205','405',
			 '306','106','206','406',
			 '307','107','207','407',
			 '308','108','208','408',
			 '309','109','209','409',
			 '310','110','210','410',
			 '311','111','211','411',
			 '312','112','212','412',
			 '313','113','213','413']
			
var cards_instatiated = []
var cardsGot = {}
var symbolPreferred : int = 0
var dealAmount : int
var cards_played : int = 0

func _ready():
	for i in cards.size():
		var card : String = get_card()
		var value : int = card.substr(1).to_int()
		var symbol : int = card.substr(0,1).to_int()
		var new_card: CardUI = normalCard.instantiate()
		new_card.card_cover = card
		new_card.value = value
		new_card.symbol = symbol
		cards_instatiated.append(new_card)
	$Player1/Hand.turn_over.connect(_on_player_played)
	$Player2/Hand.turn_over.connect(_on_player_played)
	$Player3/Hand.turn_over.connect(_on_player_played)
	$Player4/Hand.turn_over.connect(_on_player_played)
	

func get_card() -> String:
	var choice = cards.pick_random()
	var x = cards.find(choice)
	cards.remove_at(x)
	return choice

func get_card_instatiated() -> CardUI:
	var choice = cards_instatiated.pick_random()
	var x = cards_instatiated.find(choice)
	cards_instatiated.remove_at(x)
	return choice

func _on_button_pressed():
	var counter :int = 0
	for i in cards_instatiated.size():
		var card : CardUI = get_card_instatiated()
		counter += 2	
		match counter:
			1:
				pass
				"""
				card.card_visible = true
				card.player = counter
				$Player1/Hand.add_card(card)
				"""
			2:
				card.player = counter
				$Player2/Hand.add_card(card)
			3:
				#card.card_visible = true
				card.player = counter
				$Player3/Hand.add_card(card)
			4:
				card.player = counter
				$Player4/Hand.add_card(card)
		counter %= 4
	$Player1/Hand.reconnect_signals()
	$Player2/Hand.reconnect_signals()
	$Player3/Hand.reconnect_signals()
	$Player4/Hand.reconnect_signals()
	$Player1/Hand.start_turn()

func _on_help_pressed():
	pass # Replace with function body.

func _on_deal_no_triumph_pressed():
	$Panel/DealRandom.disabled = true
	$Panel/DealNoTriumph.disabled = true
	notrumph_main_hand()
	notrumph_off_hand()
	_on_button_pressed()

func _on_deal_random_pressed():
	$Panel/DealRandom.disabled = true
	$Panel/DealNoTriumph.disabled = true
	var counter :int = 1
	for i in cards_instatiated.size():
		var card : CardUI = get_card_instatiated()
		counter += 1	
		match counter:
			1:
				card.card_visible = true
				card.player = counter
				$Player1/Hand.add_card(card)
			2:
				card.player = counter
				$Player2/Hand.add_card(card)
			3:
				card.card_visible = true
				card.player = counter
				$Player3/Hand.add_card(card)
			4:
				card.player = counter
				$Player4/Hand.add_card(card)
		counter %= 4
	$Player1/Hand.reconnect_signals()
	$Player2/Hand.reconnect_signals()
	$Player3/Hand.reconnect_signals()
	$Player4/Hand.reconnect_signals()
	$Player1/Hand.start_turn()

func get_amount_of_points(pointsToReach: int):
	var point_dict = {}
	var sum = 0
	while true:
		var rand_value = randi_range(11, 14)
		if not point_dict.has(rand_value):
			point_dict[rand_value] = 1
		else:
			if point_dict[rand_value] == 4:
				continue
			point_dict[rand_value] += 1
		sum += rand_value % 10
		var rest =  sum - pointsToReach
		if rest == 0:
			return point_dict
		elif rest > 0:
			if point_dict.has(rest + 10):
				point_dict[rest + 10] -= 1
				if point_dict[rest + 10] == 0:
					point_dict.erase(rest + 10)
				return point_dict
			elif point_dict.has(rest + 11):
				point_dict[rest + 11] -= 1
				if point_dict[rest + 11] == 0:
					point_dict.erase(rest + 11)
				if point_dict.has(11):
					if point_dict[11] != 4:
						point_dict[11] += 11
			return point_dict
			
func notrumph_main_hand() -> void:
	var type = NOTRUMPHHANDS.values().pick_random()
	#var type = NOTRUMPHHANDS.UNBALANCED
	var main_hand_value = randi_range(15,17)
	var type_counter = [0,0,0,0]
	var value_dict = get_amount_of_points(main_hand_value)
	var cards_added = 0
	for value in value_dict:
		for amount in value_dict[value]:
			var rand_type = randi_range(1,4)
			if cardsGot.has((rand_type * 100) + value):
				continue
			type_counter[rand_type - 1] += 1
			search_card(rand_type, value, 1)
			cardsGot[(rand_type * 100) + value] = 0
			cards_added += 1
	match type:
		NOTRUMPHHANDS.BALANCED:
			var four_in_one = false
			for i in type_counter.size():
				var one_more = randi() % 2 == 0
				if not four_in_one and i == type_counter.size()-1:
					one_more = true
				var max_amount = 3
				if not one_more and type_counter[i] == max_amount:
					continue
				if four_in_one:
					one_more = false
				if not four_in_one and one_more:
					max_amount += 1
					four_in_one = true
				while type_counter[i] < max_amount:
					var rand_value = randi_range(2, 10)
					if cardsGot.has(((i + 1) * 100) + rand_value):
						continue
					search_card((i + 1), rand_value, 1)
					cardsGot[((i + 1) * 100) + rand_value] = 0
					type_counter[i] += 1
		NOTRUMPHHANDS.ONESEMIFAIL:
			var symbols_available = []
			var four_same_symbol = 0
			for i in type_counter.size():
				if type_counter[i] < 4:
					symbols_available.append(i)
				else:
					four_same_symbol += 1
			while true:
				if cards_added == 13:
					break
				var symbol = symbols_available.pick_random()
				if type_counter[symbol] == 2:
					var everyone_higher_than_3 = true
					for j in type_counter.size():
						if j == symbol:
							continue
						if type_counter[j] < 3:
							everyone_higher_than_3 = false
					if everyone_higher_than_3:
						symbols_available.remove_at(symbols_available.find(symbol))
						continue
				if four_same_symbol == 2 and type_counter[symbol] == 3:
					symbols_available.remove_at(symbols_available.find(symbol))
					continue
				var rand_value = randi_range(2, 10)
				if cardsGot.has(((symbol + 1) * 100) + rand_value):
					continue
				search_card((symbol + 1), rand_value, 1)
				cardsGot[((symbol + 1) * 100) + rand_value] = 0
				type_counter[symbol] += 1
				if type_counter[symbol] == 4:
					four_same_symbol += 1
					symbols_available.remove_at(symbols_available.find(symbol))
				cards_added += 1
		NOTRUMPHHANDS.UNBALANCED:
			var symbols_available = []
			var three_same_symbol = 0
			var two_row_done = false
			var low_brand_retired = 0
			for i in type_counter.size():
				if i > 1 and type_counter[i] == 3:
					three_same_symbol += 1
				else:
					symbols_available.append(i)
			while true:
				if cards_added == 13:
					break
				var symbol = symbols_available.pick_random()
				if type_counter[symbol] == 2 and not two_row_done:
					two_row_done = true
					if symbol < 2:
						if low_brand_retired == 0:
							low_brand_retired += 1
							symbols_available.remove_at(symbols_available.find(symbol))
							continue
					else:
						symbols_available.remove_at(symbols_available.find(symbol))
						continue
				var rand_value = randi_range(2, 10)
				if cardsGot.has(((symbol + 1) * 100) + rand_value):
					continue
				search_card((symbol + 1), rand_value, 1)
				cardsGot[((symbol + 1) * 100) + rand_value] = 0
				type_counter[symbol] += 1
				cards_added += 1
				if type_counter[symbol] == 3:
					three_same_symbol += 1
					if symbol < 2:
						if low_brand_retired == 1:
							continue
						else:
							low_brand_retired += 1
					symbols_available.remove_at(symbols_available.find(symbol))
				elif type_counter[symbol] == 5:
					symbols_available.remove_at(symbols_available.find(symbol))

func notrumph_off_hand() -> void:
	var main_hand_value = randi_range(0,7)
	var counter = 0
	var acumulated_value = 0
	while true:
		var rand_type = randi_range(1,4)
		var rand_value
		if(main_hand_value == acumulated_value):
			rand_value = randi_range(2,10)
		elif(main_hand_value - acumulated_value >= 5):
			rand_value = randi_range(11, 14)
		else:
			rand_value = randi_range(11, 10 + (main_hand_value-acumulated_value))
		if cardsGot.has((rand_type * 100) + rand_value):
			continue
		if rand_value > 10:
			acumulated_value += rand_value % 10
		search_card(rand_type, rand_value, 3)
		cardsGot[(rand_type * 100) + rand_value] = 0
		counter += 1
		if counter == 13:
			break

func search_card(symbol : int, value : int, player : int) -> void:
	for j in cards_instatiated.size():
		if cards_instatiated[j].symbol != symbol or cards_instatiated[j].value != value:
			continue
		cards_instatiated[j].card_visible = true
		cards_instatiated[j].player = player
		match player:
			1:
				$Player1/Hand.add_card(cards_instatiated.pop_at(j))
			2:
				$Player2/Hand.add_card(cards_instatiated.pop_at(j))
			3:
				$Player3/Hand.add_card(cards_instatiated.pop_at(j))
			4:
				$Player4/Hand.add_card(cards_instatiated.pop_at(j))
		break

func _on_player_played(player_turn_ended : int) -> void:
	var next_turn = player_turn_ended + 1
	cards_played += 1
	if next_turn > 4:
		next_turn = 1
	if cards_played == 4:
		next_turn = await check_winner_of_round()
		cards_played = 0
	if $Rounds.get_child_count() == 13:
		print("se acabo la partida")
		return
	match next_turn:
		1:
			player1_turn.emit()
		2:
			player2_turn.emit()
		3:
			player3_turn.emit()
		4:
			player4_turn.emit()

func check_winner_of_round() -> int:
	var tween = create_tween().set_parallel(true)
	var table_layer := get_tree().get_first_node_in_group("table")
	var winner : int = 0
	var winner_symbol : int
	var winner_value : int
	var first = true
	var direction = Vector2(0,0)
	for child in table_layer.get_children():
		var card_ui = child as CardUI
		if first:
			winner = card_ui.player
			winner_symbol = card_ui.symbol
			winner_value = card_ui.value
			first = false
		else:
			match symbolPreferred:
				0:
					if winner_symbol != card_ui.symbol:
						continue
					else:
						if winner_value < card_ui.value:
							winner = card_ui.player
							winner_symbol = card_ui.symbol
							winner_value = card_ui.value
				_:
					if card_ui.symbol == symbolPreferred:
						if winner_symbol != symbolPreferred or (winner_value < card_ui.value and winner_symbol == symbolPreferred):
							winner = card_ui.player
							winner_symbol = card_ui.symbol
							winner_value = card_ui.value
	var new_node : Node = Node.new()
	match winner:
		1:
			direction = Vector2(640,800)
			$Panel/WonCounter.text = str($Panel/WonCounter.text.to_int() + 1 )
		2:
			direction = Vector2(-100,275)
			$Panel/LostCounter.text = str($Panel/LostCounter.text.to_int() + 1 )
		3:
			direction = Vector2(640,-200)
			$Panel/WonCounter.text = str($Panel/WonCounter.text.to_int() + 1 )
		4:
			direction = Vector2(1380,275)
			$Panel/LostCounter.text = str($Panel/LostCounter.text.to_int() + 1 )
	for child in table_layer.get_children():
		tween.tween_property(child, "global_position", direction , 1)
	await tween.finished
	for child in table_layer.get_children():
		child.reparent(new_node)
	$Rounds.add_child(new_node)
	return winner

func _on_reset_pressed():
	get_tree().reload_current_scene()
	await self.ready
	_on_deal_no_triumph_pressed()
