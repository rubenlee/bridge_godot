class_name Table
extends Node2D

@onready var normalCard: PackedScene = preload("res://scenes/cardUi/card_ui.tscn")
const TABLE = preload("res://scenes/table/table.tscn")

enum NOTRUMPHHANDS {BALANCED, ONESEMIFAIL, UNBALANCED}
signal player1_turn()
signal player2_turn()
signal player3_turn()
signal player4_turn()

var value_dict = {}
var hands_playable = []
var rounds_done = []
var hand_selected = 0
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
var bidding_state : bool = true

func _ready():
	prepare_cards()
	$Player1/Hand.turn_over.connect(_on_player_played)
	$Oeste/Hand.turn_over.connect(_on_player_played)
	$Norte/Hand.turn_over.connect(_on_player_played)
	$Este/Hand.turn_over.connect(_on_player_played)
	$Oeste/Hand.bidding_over.connect(_on_pre_bidding_deal)
	$Norte/Hand.bidding_over.connect(_on_pre_bidding_deal)
	$Este/Hand.bidding_over.connect(_on_pre_bidding_deal)
	$bidding.biddings_over.connect(_on_bidding_over)
	$Este/Hand.setPlayerInd(4)
	$Oeste/Hand.setPlayerInd(2)
	$Norte/Hand.setPlayerInd(3)
	$Player1/Hand.setPlayerInd(1)
	$Norte/Hand.mouse_filter = $Norte/Hand.MOUSE_FILTER_IGNORE
	#_on_deal_no_triumph_pressed()
	prepare_table()
	
func prepare_cards() -> void:
	for i in cards.size():
		var card : String = get_card()
		var value : int = card.substr(1).to_int()
		var symbol : int = card.substr(0,1).to_int()
		var new_card: CardUI = normalCard.instantiate()
		new_card.card_cover = card
		new_card.value = value
		new_card.symbol = symbol
		cards_instatiated.append(new_card)
		
func prepare_table() -> void:
	var player = 0
	if Global.hands.is_empty():
		_on_deal_random_pressed()
	else:
		var selected_play = Global.hands.pick_random()
		hand_selected = hands_playable.find(selected_play)
		player = selected_play["Dealer"]
		match selected_play["Game"]:
			0:
				_on_deal_no_triumph_pressed()
			_:
				_on_deal_random_pressed()
	if player == 0:
		player = randi_range(1,4)
	if player == 1:
		$bidding.toggle_buttons(false)	
	else:
		$bidding.toggle_buttons(true)	
	match player:
		3:
			$bidding.set_first_turn(2)
			$Norte/Hand.bidding_thinking($bidding.highest_vote, $bidding.highest_vote_symbol, $bidding.highest_player_vote)
		2:
			$bidding.set_first_turn(1)
			$Oeste/Hand.bidding_thinking($bidding.highest_vote, $bidding.highest_vote_symbol, $bidding.highest_player_vote)
		4:
			$bidding.set_first_turn(3)
			$Este/Hand.bidding_thinking($bidding.highest_vote, $bidding.highest_vote_symbol, $bidding.highest_player_vote)

func _on_pre_bidding_deal(player : int, deal : String) -> void:
	if player != 1:
		$bidding.deal_pressed(deal)
	_on_bidding_deal(player, deal)

func _on_bidding_deal(player : int, deal : String) -> void:
	var next_turn = player + 1
	if next_turn > 4:
		next_turn = 1
	if next_turn == 1 and bidding_state:
		$bidding.toggle_buttons(false)	
	else:
		$bidding.toggle_buttons(true)	
	await get_tree().create_timer(0.5).timeout 
	if $bidding.dealt:
		return
	match next_turn:
		2:
			$Oeste/Hand.bidding_thinking($bidding.highest_vote, $bidding.highest_vote_symbol, $bidding.highest_player_vote)
		3:
			$Norte/Hand.bidding_thinking($bidding.highest_vote, $bidding.highest_vote_symbol, $bidding.highest_player_vote)
		4:
			$Este/Hand.bidding_thinking($bidding.highest_vote, $bidding.highest_vote_symbol, $bidding.highest_player_vote)

func _on_bidding_over(player_won_bid : int, symbol : int, deal_amount : int):
	if deal_amount == 0:
		$Panel2/VBoxContainer/HBoxContainer/Label2.text = "Ninguna"
		$Panel/GameMode.text = "Apuesta no completada"
		$Panel2/VBoxContainer/HBoxContainer2/Label2.text = "nadie"
		await start_animation()
		return
	bidding_state = false
	dealAmount = deal_amount 
	symbolPreferred = symbol
	var player_start = (player_won_bid + 1) % 4
	var full_string = ""
	match symbolPreferred:
		0: 
			full_string = "Sin triunfo " + str(dealAmount)
		_:
			full_string = "Sin triunfo " + str(dealAmount)
	$Panel2/VBoxContainer/HBoxContainer/Label2.text = full_string
	$Panel/GameMode.text = full_string
	match player_start:
		1:
			$Panel2/VBoxContainer/HBoxContainer2/Label2.text = "SUR"
			await start_animation()
			$Player1/Hand.start_turn()
		0:
			$Panel2/VBoxContainer/HBoxContainer2/Label2.text = "ESTE"
			await start_animation()
			$Este/Hand.start_turn()
		3:
			$Panel2/VBoxContainer/HBoxContainer2/Label2.text = "NORTE"
			await start_animation()
			$Norte/Hand.start_turn()
		2:
			$Panel2/VBoxContainer/HBoxContainer2/Label2.text = "OESTE"
			await start_animation()
			$Oeste/Hand.start_turn()
	$Norte/Hand.mouse_filter = $Norte/Hand.MOUSE_FILTER_PASS
	for child in $Norte/Hand.get_children():
		child.visible = true

func start_animation() -> void:
	$Panel2/AnimationPlayer.play("simple_pop_up")
	await $Panel2/AnimationPlayer.animation_finished
	await get_tree().create_timer(1).timeout 
	$Panel2/AnimationPlayer.play("simple_pop_up_disappear")
	await $Panel2/AnimationPlayer.animation_finished
	$bidding.visible = false

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

func fill_rest_hands(rest_players : Array):
	var counter = 0
	for i in cards_instatiated.size():
		var card : CardUI = get_card_instatiated()	
		match rest_players[counter]:
			1:
				card.card_visible = true
				card.player = rest_players[counter]
				$Player1/Hand.add_card(card)
			2:
				card.player = rest_players[counter]
				$Oeste/Hand.add_card(card)
			3:
				card.visible = false
				card.player = rest_players[counter]
				$Norte/Hand.add_card(card)
			4:
				card.player = rest_players[counter]
				$Este/Hand.add_card(card)
		counter = (counter + 1) % 2
	$Player1/Hand.reconnect_signals()
	$Oeste/Hand.reconnect_signals()
	$Norte/Hand.reconnect_signals()
	$Este/Hand.reconnect_signals()

func _on_help_pressed():
	pass # Replace with function body.

func _on_deal_no_triumph_pressed():
	$Panel/DealRandom.disabled = true
	$Panel/DealNoTriumph.disabled = true
	if Global.hands[hand_selected]["AffectedHands"] == 0:
		if Global.hands[hand_selected]["inverse"]:
			notrumph_main_hand(1, Global.hands[hand_selected]["offMinHonorPoints"], Global.hands[hand_selected]["offMaxHonorPoints"])
			notrumph_off_hand(3, Global.hands[hand_selected]["mainMinHonorPoints"], Global.hands[hand_selected]["mainMaxHonorPoints"])
		else:
			notrumph_main_hand(1, Global.hands[hand_selected]["mainMinHonorPoints"], Global.hands[hand_selected]["mainMaxHonorPoints"])
			notrumph_off_hand(3, Global.hands[hand_selected]["offMinHonorPoints"], Global.hands[hand_selected]["offMaxHonorPoints"])
		fill_rest_hands([2,4])
	else:
		notrumph_main_hand(4, Global.hands[hand_selected]["mainMinHonorPoints"], Global.hands[hand_selected]["mainMaxHonorPoints"])
		notrumph_off_hand(2, Global.hands[hand_selected]["mainMinHonorPoints"], Global.hands[hand_selected]["mainMaxHonorPoints"])
		fill_rest_hands([1,3])

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
				$Oeste/Hand.add_card(card)
			3:
				card.visible = false
				card.card_visible = true
				card.player = counter
				$Norte/Hand.add_card(card)
			4:
				card.player = counter
				$Este/Hand.add_card(card)
		counter %= 4
	$Player1/Hand.reconnect_signals()
	$Oeste/Hand.reconnect_signals()
	$Norte/Hand.reconnect_signals()
	$Este/Hand.reconnect_signals()
	#$Player1/Hand.start_turn()

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
			
func notrumph_main_hand(player : int, min_value : int, max_value : int) -> void:
	#var type = NOTRUMPHHANDS.values().pick_random()
	var type = NOTRUMPHHANDS.UNBALANCED
	var main_hand_value = randi_range(min_value, max_value)
	var type_counter = [0,0,0,0]
	value_dict = get_amount_of_points(main_hand_value)
	var cards_added = 0
	for value in value_dict:
		var amount = value_dict[value]
		while amount != 0:
			var rand_type = randi_range(1,4)
			if cardsGot.has((rand_type * 100) + value):
				continue
			type_counter[rand_type - 1] += 1
			search_card(rand_type, value, player)
			cardsGot[(rand_type * 100) + value] = 0
			cards_added += 1
			amount -= 1
	match type:
		NOTRUMPHHANDS.BALANCED:
			notrumph_balanced(type_counter, player, cards_added)
		NOTRUMPHHANDS.ONESEMIFAIL:
			notrump_semifail(type_counter, player, cards_added)
		NOTRUMPHHANDS.UNBALANCED:
			notrump_unbalanced(type_counter, player, cards_added)
					
func notrumph_balanced(type_counter : Array, player : int, cards_added : int) -> void :
	var symbols_available = {}
	var four_in_one = true
	for i in type_counter.size():
		symbols_available[i+1] = type_counter[i] 
	for i in symbols_available:
		if symbols_available[i] == 4:
			four_in_one = false
			symbols_available.erase(i)
			break
	if not four_in_one:
		for i in symbols_available:
			if symbols_available[i] == 3:
				symbols_available.erase(i)
	while true:
		var rand_value = randi_range(2, 10)
		var symbol = randi_range(1, 4)
		if not symbols_available.has(symbol):
			continue
		if cardsGot.has((symbol * 100) + rand_value):
			continue
		search_card(symbol, rand_value, player)
		cardsGot[(symbol * 100) + rand_value] = 0
		symbols_available[symbol] += 1
		cards_added += 1
		if four_in_one and symbols_available[symbol] == 4:
			symbols_available.erase(symbol)
			four_in_one = false
			for i in symbols_available:
				if symbols_available[i] == 3:
					symbols_available.erase(i)
		elif not four_in_one and symbols_available[symbol] == 3:
			symbols_available.erase(symbol)
		if symbols_available.is_empty() or cards_added == 13:
			break
	
func notrump_semifail(type_counter : Array, player : int, cards_added : int) -> void:
	var symbols_available = {}
	var four_same_symbol = 0
	var already_found_two = false
	for i in type_counter.size():
		if type_counter[i] < 4:
			symbols_available[i+1] = type_counter[i]
		else:
			four_same_symbol += 1
	while true:
		if cards_added == 13 or symbols_available.is_empty():
			break
		var rand_value = randi_range(2, 10)
		var symbol = randi_range(1, 4)
		if not symbols_available.has(symbol):
			continue
		if symbols_available[symbol] == 2 and not already_found_two:
			var all_higher_than_two = true
			for i in symbols_available:
				if symbols_available[i] < 2:
					all_higher_than_two = false
			if all_higher_than_two:
				already_found_two = true
				symbols_available.erase(symbol)
				continue
		if cardsGot.has(((symbol) * 100) + rand_value):
			continue
		search_card((symbol), rand_value, player)
		cardsGot[((symbol) * 100) + rand_value] = 0
		symbols_available[symbol] += 1
		if four_same_symbol >= 2 and symbols_available[symbol] == 3:
			symbols_available.erase(symbol)
		elif symbols_available[symbol] == 4:
			four_same_symbol += 1
			symbols_available.erase(symbol)
		cards_added += 1

func notrump_unbalanced(type_counter : Array, player : int, cards_added : int) -> void:
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
		search_card((symbol + 1), rand_value, player)
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
	
func notrumph_off_hand(player : int, min_value : int, max_value : int) -> void:
	var leftover_points = {}
	var combination = {}
	for i in value_dict:
		var lefts = 4 - value_dict[i]
		combination[i] = 0
		if i != 0: 
			leftover_points[i] = lefts
	var tries = 0
	var accumulated = 0
	var counter = 0
	var leftover_points_copy = leftover_points.duplicate()
	var main_hand_value = randi_range(min_value, max_value)
	var remaining = main_hand_value
	while true:
		if main_hand_value == 0:
			break
		var rand_type = randi_range(1,4)
		var symbol = randi_range(11, 14)
		if not leftover_points.has(symbol):
			tries += 1
			if tries >= 15:
				for j in combination:
					combination[j] = 0
				accumulated = 0
				leftover_points = leftover_points_copy.duplicate()
				remaining = randi_range(min_value, max_value)
			continue
		if cardsGot.has((rand_type * 100) + symbol):
			tries += 1
			if tries >= 15:
				for j in combination:
					combination[j] = 0
				accumulated = 0
				leftover_points = leftover_points_copy.duplicate()
				remaining = randi_range(min_value, max_value)
			continue
		if remaining - ((symbol-10) + accumulated) == 0:
			combination[symbol] += 1
			break
		elif remaining - ((symbol-10) + accumulated) > 0:
			combination[symbol] += 1
			leftover_points[symbol] -= 1
			if leftover_points[symbol] == 0:
				leftover_points.erase(symbol)
			accumulated += (symbol - 10)
		else:
			tries += 1
			if tries >= 15:
				for j in combination:
					combination[j] = 0
				accumulated = 0
				leftover_points = leftover_points_copy.duplicate()
				remaining = randi_range(min_value, max_value)
	while true:
		if combination.is_empty():
			break
		var rand_type = randi_range(1,4)
		var symbol = randi_range(11, 14)
		if not combination.has(symbol):
			continue
		if combination[symbol] <= 0:
			combination.erase(symbol)
			continue
		if cardsGot.has((rand_type * 100) + symbol):
			continue
		search_card(rand_type, symbol , player)
		cardsGot[(rand_type * 100) + symbol] = 0
		counter += 1
		combination[symbol] -= 1
	while true:
		var rand_type = randi_range(1,4)
		var rand_value = randi_range(2, 10)
		if cardsGot.has((rand_type * 100) + rand_value):
			continue
		search_card(rand_type, rand_value, player)
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
				$Oeste/Hand.add_card(cards_instatiated.pop_at(j))
			3:
				cards_instatiated[j].visible = false
				$Norte/Hand.add_card(cards_instatiated.pop_at(j))
			4:
				$Este/Hand.add_card(cards_instatiated.pop_at(j))
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
				5:
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

func _on_return_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/configuration_deal.tscn")
