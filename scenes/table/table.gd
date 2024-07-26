class_name Table
extends Node2D

@onready var normalCard: PackedScene = preload("res://scenes/cardUi/card_ui.tscn")
const TABLE = preload("res://scenes/table/table.tscn")

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

var value_dict := {}
var hands_playable := []
var rounds_done := []
var hand_selected := 0
var player_won_bid := -1
var player_turn := -1
var cards_instatiated := []
var cardsGot := {}
var symbolPreferred := 0
var dealAmount : int
var cards_played := 0
var bidding_state := true
var dead_hand : Hand
#var bridge_thinker :=  bridge.new()
var seats := {}

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
	
func clear_seats() -> void:
	seats.clear()
	seats["south"] = {}
	seats["west"] = {}
	seats["north"] = {}
	seats["east"] = {}
	for i in seats:
		seats[i]["hcp"] = 0
		seats[i]["dp"] = 0
		seats[i]["suits"] = [0,0,0,0]
		seats[i]["cards"] = []
		seats[i]["regular"] = false
		seats[i]["balanced"] = false

func generate_hands() -> void:
	clear_seats()
	var all_cards = cards_instatiated.duplicate()
	all_cards.shuffle()
	for i in seats:
		for p in range(13):
			var random_card : CardUI = all_cards.pop_front()
			if random_card.value > 10:
				seats[i]["hcp"] += random_card.value - 10
			seats[i]["suits"][random_card.symbol - 1] += 1
			seats[i]["cards"].insert(get_index_order(i, random_card), random_card)
		seats[i]["regular"] = checkRegular(seats[i]["suits"], false)
		seats[i]["balanced"] = checkRegular(seats[i]["suits"], true)
		for p in seats[i]["suits"]:
			if p < 3:
				seats[i]["dp"] += 3 - p

func get_index_order(index : String, random_card : CardUI ) -> int:
	var result = 0
	for temp_node : CardUI in seats[index]["cards"]:
		if random_card.symbol > temp_node.symbol:
			break
		elif random_card.symbol == temp_node.symbol:
			if random_card.value < temp_node.value:
				result += 1
		else:
			result += 1
	return result

func checkRegular(hand_suits : Array, balanced : bool):
	var result = false
	if hand_suits.count(0) != 0 or hand_suits.count(1) != 0:
		return result
	if hand_suits.count(3) == 3:
		if hand_suits.count(4) == 1:
			result = true
	elif hand_suits.count(2) == 1:
		if hand_suits.count(5) == 1:
			if hand_suits.count(3) == 2:
				if balanced:
					if hand_suits.find(5) < 1:
						result = true
				else:
					result = true
		if hand_suits.count(4) == 2:
			result = true
	return result

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
		hand_selected = randi_range(0, Global.hands.size() - 1)
		var selected_play = Global.hands[hand_selected]
		player = selected_play["Dealer"]
		match selected_play["Game"]:
			4:
				_on_deal_no_triumph_pressed()
			0:
				on_deal_suit()
			1:
				on_deal_suit()
			2:
				on_deal_suit()
			3:
				on_deal_suit()
			_:
				_on_deal_random_pressed()
	if player == 0:
		player = randi_range(1,4)
	if player == 1:
		$bidding.toggle_buttons(false)	
		$Panel/Help.disabled = false
	else:
		$bidding.toggle_buttons(true)	
		$Panel/Help.disabled = true
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
		$Panel/Help.disabled = false
	else:
		$bidding.toggle_buttons(true)	
		$Panel/Help.disabled = true
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
	self.player_won_bid = player_won_bid
	bidding_state = false
	dealAmount = deal_amount 
	symbolPreferred = symbol
	var player_start = (player_won_bid + 1) % 4
	var full_string = ""
	match symbolPreferred:
		0: 
			full_string = "Sin triunfo " + str(dealAmount)
		1:
			full_string = "Trebol " + str(dealAmount)
		2:
			full_string = "Diamante " + str(dealAmount)
		3:
			full_string = "Corazón " + str(dealAmount)
		4:
			full_string = "Picas " + str(dealAmount)
		_:
			full_string = "Sin triunfo " + str(dealAmount)
	$Panel2/VBoxContainer/HBoxContainer/Label2.text = full_string
	$Panel/GameMode.text = full_string
	$Norte/Hand.mouse_filter = $Norte/Hand.MOUSE_FILTER_PASS
	var node
	match player_start:
		1:
			$Panel2/VBoxContainer/HBoxContainer2/Label2.text = "SUR"
			$Oeste/visibleHand.visible = true
			dead_hand = $Este/Hand
			$Norte/Hand.position -= Vector2(0,125)
			await start_animation()
			node = $Player1/Hand
			player_turn = 1
		0:
			$Panel2/VBoxContainer/HBoxContainer2/Label2.text = "ESTE"
			dead_hand = $Player1/Hand
			await start_animation()
			node = $Este/Hand
			player_turn = 2
		3:
			$Panel2/VBoxContainer/HBoxContainer2/Label2.text = "NORTE"
			$Este/visibleHand.visible = true
			dead_hand = $Este/Hand
			$Norte/Hand.position -= Vector2(0,125)
			await start_animation()
			node = $Norte/Hand
			player_turn = 3
		2:
			$Panel2/VBoxContainer/HBoxContainer2/Label2.text = "OESTE"
			dead_hand = $Norte/Hand
			await start_animation()
			node = $Oeste/Hand
			player_turn = 4
	for child in $Norte/Hand.get_children():
		child.visible = true
		if player_won_bid % 2 == 0:
			child.card_visible = false
			child.show_card()
	for child in $Este/Hand.get_children():
		child.card_visible = false
	for child in $Oeste/Hand.get_children():
		child.card_visible = false
	node.start_turn()
	
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

func _on_help_pressed() -> void:
	if bidding_state:
		bid_help()
		$helpPanel/AnimationPlayer.play("slide_in")
		await get_tree().create_timer(5).timeout
		$helpPanel/AnimationPlayer.play("slide_out")
	else:
		match symbolPreferred:
			5:
				no_trump_help()
				$helpPanel/AnimationPlayer.play("slide_in")
				await get_tree().create_timer(5).timeout
				$helpPanel/AnimationPlayer.play("slide_out")
			_:
				symbol_help()
				$helpPanel/AnimationPlayer.play("slide_in")
				await get_tree().create_timer(5).timeout
				$helpPanel/AnimationPlayer.play("slide_out")

func bid_help() -> void:
	var highest_value := 0
	var symbol := 0
	var highest_player := 0
	var highest_bid  := ""
	var friend_bid := ""
	for i : String in $bidding.bid_log:
		if i.is_empty():
			continue
		if i.substr(2) == '3':
			friend_bid = i
			if friend_bid.substr(1,1).to_int() > symbol:
				if friend_bid.substr(0,1).to_int() > highest_value:
					highest_value = friend_bid.substr(0,1).to_int()
					symbol = friend_bid.substr(1,1).to_int()
					highest_player = 3
		else:
			highest_bid = i
			if highest_bid.substr(1,1).to_int() > symbol:
				if highest_bid.substr(0,1).to_int() > highest_value:
					highest_value = highest_bid.substr(0,1).to_int()
					symbol = highest_bid.substr(1,1).to_int()
					highest_player = i.substr(2).to_int()
	if highest_player == 0:
		if seats["south"].balanced:
			if (seats["south"]["hcp"] >= 15 and seats["south"]["hcp"] <= 17):
				$helpPanel/RichTextLabel.text = "Tienes una manor equilibrada y con suficientes puntos de honor para abrir de 1 sin triunfo\n"
				return
			elif seats["south"]["hcp"] >= 20 and seats["south"]["hcp"] <= 22:
				$helpPanel/RichTextLabel.text = "Tienes una manor equilibrada y con suficientes puntos de honor para abrir de 2 sin triunfo\n"
				return	
		var high_trump := false
		for i in range(2,4):
			if seats["south"]["suits"][i] >= 5:
				high_trump = true
		if high_trump:
			if (seats["south"]["hcp"] >= 12 and seats["south"]["hcp"] <= 20):
				$helpPanel/RichTextLabel.text = "Tienes al menos  y con suficientes puntos de honor para abrir de 1 de palo mayor\n"
				return
		$helpPanel/RichTextLabel.text = "Tienes muy pocos puntos de honor o combinación disponible\n"
	else:
		if highest_player == 3:
			match symbol:
				5:
					if (seats["south"]["hcp"] >= 8 and seats["south"]["hcp"] <= 9):
						$helpPanel/RichTextLabel.text = "Puedes apoyar a tu compañero aumentando a 2 sin triunfo\n"
						return
					elif (seats["south"]["hcp"] >= 10 and seats["south"]["hcp"] <= 15):
						$helpPanel/RichTextLabel.text = "Puedes apoyar a tu compañero aumentando a 3 sin triunfo\n"
						return
				3,4:
					if seats["south"]["suits"][symbol] >= 5:
						if (seats["south"]["hcp"] + seats["south"]["dp"] >= 6 and seats["south"]["hcp"] + seats["south"]["dp"] <= 10):
							$helpPanel/RichTextLabel.text = "Puedes apoyar a tu compañero aumentando a 2 del mismo palo\n"
							return
						elif (seats["south"]["hcp"] + seats["south"]["dp"] >= 11 and seats["south"]["hcp"] + seats["south"]["dp"] <= 12):
							$helpPanel/RichTextLabel.text = "Puedes apoyar a tu compañero aumentando a 3 del mismo palo\n"
							return
						elif (seats["south"]["hcp"] + seats["south"]["dp"] >= 13 and seats["south"]["hcp"] + seats["south"]["dp"] <= 15):
							$helpPanel/RichTextLabel.text = "Puedes apoyar a tu compañero aumentando a 4 del mismo palo\n"
							return
					else:
						if seats["south"]["suits"][symbol] < 4 and seats["south"]["regular"]:
							if (seats["south"]["hcp"] >= 6 and seats["south"]["hcp"] <= 10):
								$helpPanel/RichTextLabel.text = "Puedes cambiar a 1 sin triunfo\n"
								return
							elif (seats["south"]["hcp"] >= 11 and seats["south"]["hcp"] <= 12):
								$helpPanel/RichTextLabel.text = "Puedes cambiar a 2 sin triunfo\n"
								return
							elif (seats["south"]["hcp"] >= 13 and seats["south"]["hcp"] <= 15):
								$helpPanel/RichTextLabel.text = "Puedes cambiar a 3 sin triunfo\n"
								return
				_:
					pass
			$helpPanel/RichTextLabel.text = "Ningún movimiento notable que hacer, recomendado pasar\n"

func no_trump_help() -> void:
	var hand_to_move : Hand
	var dead_hand_ally = false
	$helpPanel/RichTextLabel.clear()
	if dead_hand.playerInd == 3:
		dead_hand_ally = true
	var temp_dead_hand = dead_hand
	if player_turn == 1:
		hand_to_move = $Player1/Hand
		if hand_to_move.playerInd == dead_hand.playerInd:
			temp_dead_hand = $Norte/Hand
	else:
		hand_to_move = $Norte/Hand
		if hand_to_move.playerInd == dead_hand.playerInd:
			temp_dead_hand = $Player1/Hand
	var cards_in_table = get_cards_and_check()
	if not cards_in_table.is_empty():
		if cards_in_table.front() == -1:
			$helpPanel/RichTextLabel.append_text("El oponente ha jugado un As, a lo que se perdera la baza. \n Se recomienda tirar una carta de valor bajo.")
			return
		if not hand_to_move.cards_dict[cards_in_table[0].symbol].is_empty():
			$helpPanel/RichTextLabel.text = "Al no tener cartas del tipo de la que se esta jugando la baza.\n Se recomienda tirar una carta de bajo valor"
			return
	$helpPanel/RichTextLabel.text = "Tienes " + str(count_winning_hands(hand_to_move, temp_dead_hand)) + " bazas ganadoras directas y necesitas ganar " + str(dealAmount + 6) + "\n"
	if $TableCards.get_child_count() != 0:
		$helpPanel/RichTextLabel.append_text("Asegura todas las bazas que puedas ganar siempre")
	else:
		$helpPanel/RichTextLabel.append_text("Si tienes una secuencia de honores juega la mayor\n En caso de no tener tira la 4ª del palo más largo que tengas")
		return

func symbol_help():
	var hand_to_move : Hand
	var dead_hand_ally = false
	$helpPanel/RichTextLabel.text.clear()
	if dead_hand.playerInd == 3:
		dead_hand_ally = true
	if player_turn == 1:
		hand_to_move = $Player1/Hand
	else:
		hand_to_move = $Norte/Hand
	var cards_in_table = get_cards_and_check()
	if not cards_in_table.is_empty():
		if cards_in_table.front() == -1 and cards_in_table.front().symbol == symbolPreferred:
			$helpPanel/RichTextLabel.append_text("El oponente ha jugado un As, a lo que se perdera la baza. \n Se recomienda tirar una carta de valor bajo.")
			return
		if not hand_to_move.cards_dict[cards_in_table[0].symbol].is_empty():
			if cards_in_table[0].symbol != symbolPreferred and not hand_to_move.cards_dict[symbolPreferred].is_empty():
				$helpPanel/RichTextLabel.text = "Puedes fallar con una carta del palo al que se esta jugando y poder ganar la ronda"
				return
			else:
				$helpPanel/RichTextLabel.text = "Al no tener carta del palo que se esta jugando, falla con cualquier carta"
				return
			return
	$helpPanel/RichTextLabel.append_text("Intenta descartarte del palo más corto para poder fallar al palo ganador")
	'''
	if $TableCards.get_child_count() != 0:
		$helpPanel/RichTextLabel.append_text("Asegura todas las bazas que puedas ganar siempre")
	else:
		$helpPanel/RichTextLabel.append_text("Si tienes una secuencia de honores juega la mayor\n En caso de no tener tira la 4ª del palo más largo que tengas")
		return
	'''

func get_cards_and_check() -> Array:
	var result = []
	for child : CardUI in $TableCards.get_children():
		if child.value == 14 and (symbolPreferred == child.symbol or symbolPreferred == 5):
			if child.player == 2 or child.player == 4:
				result.append(-1)
				return result
	return result

func count_winning_hands(main_hand : Hand, dead_hand_temp : Hand) -> int:
	var result : int = 0
	var main_dict = main_hand.cards_dict
	var dead_dict = dead_hand_temp.cards_dict
	for i in range(1,5):
		var had_previous : bool = false
		var max_winning : int
		if main_dict.has(i) and dead_dict.has(i):
			if main_dict[i].size() >= dead_dict[i].size():
				max_winning = main_dict[i].size()
			else:
				max_winning = dead_dict[i].size()
		for j in range(14, 11, -1):
			if main_dict.has(i):
				if main_dict[i].find(j) != -1:
					if had_previous or j == 14:
						result += 1
						had_previous = true
						if result == max_winning:
							break
						continue
			if dead_dict.has(i):
				if dead_dict[i].find(j) != -1:
					if had_previous or j == 14:
						result += 1
						had_previous = true
						if result == max_winning:
							break
						continue
	return result

func on_deal_suit():
	var tries := 0
	var seat_string := "north"
	var seat_dead := "south"
	if Global.hands[hand_selected]["AffectedHands"] != 0:
		seat_string = "west"
		seat_dead = "east"
	var main_max = Global.hands[hand_selected]["mainMaxHonorPoints"]
	var main_min = Global.hands[hand_selected]["mainMinHonorPoints"]
	var dead_max = Global.hands[hand_selected]["offMaxHonorPoints"]
	var dead_min = Global.hands[hand_selected]["offMinHonorPoints"]
	var main_dist_min = Global.hands[hand_selected]["mainMinDistributionPoints"]
	var main_dist_max = Global.hands[hand_selected]["mainMaxDistributionPoints"]
	var dead_dist_max = Global.hands[hand_selected]["offMaxDistributionPoints"]
	var dead_dist_min = Global.hands[hand_selected]["offMinDistributionPoints"]
	if Global.hands[hand_selected]["inverse"]:
		var temp := seat_string
		seat_string = seat_dead
		seat_dead = temp
		main_max = Global.hands[hand_selected]["offMaxHonorPoints"]
		main_min = Global.hands[hand_selected]["offMinHonorPoints"]
		dead_max = Global.hands[hand_selected]["mainMaxHonorPoints"]
		dead_min = Global.hands[hand_selected]["mainMinHonorPoints"]
		main_dist_min = Global.hands[hand_selected]["offMinDistributionPoints"]
		main_dist_max = Global.hands[hand_selected]["offMaxDistributionPoints"]
		dead_dist_max = Global.hands[hand_selected]["mainMaxDistributionPoints"]
		dead_dist_min = Global.hands[hand_selected]["mainMinDistributionPoints"]
	while true:
		generate_hands()	
		tries += 1
		if (seats[seat_string]["suits"][Global.hands[hand_selected]["Game"]] > 4 and \
			seats[seat_string]["hcp"] >= main_min and seats[seat_string]["hcp"] <= main_max and \
			seats[seat_string]["dp"] >= main_dist_min and seats[seat_string]["dp"] <= main_dist_max) and \
			(seats[seat_dead]["suits"][Global.hands[hand_selected]["Game"]] > 2 and \
			seats[seat_dead]["hcp"] >= dead_min and seats[seat_dead]["hcp"] <= dead_max and \
			seats[seat_dead]["dp"] >= dead_dist_min and seats[seat_dead]["dp"] <= dead_dist_max):
			break
	print(tries)
	deal_cards_seats()

func _on_deal_no_triumph_pressed() -> void:
	var tries := 0
	var seat_string := "north"
	var seat_dead := "south"
	if Global.hands[hand_selected]["AffectedHands"] != 0:
		seat_string = "west"
		seat_dead = "east"
	var main_max = Global.hands[hand_selected]["mainMaxHonorPoints"]
	var main_min = Global.hands[hand_selected]["mainMinHonorPoints"]
	var dead_max = Global.hands[hand_selected]["offMaxHonorPoints"]
	var dead_min = Global.hands[hand_selected]["offMinHonorPoints"]
	if Global.hands[hand_selected]["inverse"]:
		var temp := seat_string
		seat_string = seat_dead
		seat_dead = temp
		main_max = Global.hands[hand_selected]["offMaxHonorPoints"]
		main_min = Global.hands[hand_selected]["offMinHonorPoints"]
		dead_max = Global.hands[hand_selected]["mainMaxHonorPoints"]
		dead_min = Global.hands[hand_selected]["mainMinHonorPoints"]
	while true:
		generate_hands()	
		tries += 1
		if (seats[seat_string]["balanced"] and seats[seat_string]["hcp"] >= main_min and seats[seat_string]["hcp"] <= main_max) and (seats[seat_dead]["hcp"] >= dead_min and seats[seat_dead]["hcp"] <= dead_max):
			break
	print(tries)
	deal_cards_seats()

func deal_cards_seats():
	for i in seats:
		for j : CardUI in seats[i]["cards"]:
			match i:
				"north":
					j.visible = false
					j.card_visible = true
					j.player = 3
					$Norte/Hand.regular = seats[i]["regular"]
					$Norte/Hand.balanced = seats[i]["balanced"]
					$Norte/Hand.distribution_points = seats[i]["dp"]
					$Norte/Hand.add_card(j)
				"south":
					j.card_visible = true
					j.player = 1
					$Player1/Hand.regular = seats[i]["regular"]
					$Player1/Hand.balanced = seats[i]["balanced"]
					$Player1/Hand.distribution_points = seats[i]["dp"]
					$Player1/Hand.add_card(j)
				"east":
					j.player = 4
					$Este/Hand.regular = seats[i]["regular"]
					$Este/Hand.balanced = seats[i]["balanced"]
					$Este/Hand.distribution_points = seats[i]["dp"]
					$Este/Hand.add_card(j)
					prepare_visible_hand(4, j.value, j.symbol, j.card_cover)
				"west":
					j.player = 2
					$Oeste/Hand.regular = seats[i]["regular"]
					$Oeste/Hand.balanced = seats[i]["balanced"]
					$Oeste/Hand.distribution_points = seats[i]["dp"]
					$Oeste/Hand.add_card(j)
					prepare_visible_hand(2, j.value, j.symbol, j.card_cover)
	$Player1/Hand.reconnect_signals()
	$Oeste/Hand.reconnect_signals()
	$Norte/Hand.reconnect_signals()
	$Este/Hand.reconnect_signals()

func prepare_visible_hand(hand : int, cardValue : int, cardSymbol : int, resource : String) -> void:
	var newRect : TextureRect = TextureRect.new()
	newRect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	newRect.texture = load("res://Graphics/cards/" + resource + ".png")
	newRect.name = str(cardSymbol) + str(cardValue)
	newRect.custom_minimum_size = Vector2(75,125)
	newRect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var hcontainer : HBoxContainer
	if hand == 2:
		hcontainer = get_node("Oeste/visibleHand/" + str(cardSymbol))
	else:
		hcontainer = get_node("Este/visibleHand/" + str(cardSymbol))
	hcontainer.add_child(newRect)

func _on_deal_random_pressed() -> void:
	generate_hands()
	deal_cards_seats()

func removeVisibleCar(player : int) -> void:
	var hcontainer : HBoxContainer
	var last_card : CardUI = $TableCards.get_children().back()
	var card_name := str(last_card.symbol) + str(last_card.value)
	if player == 2:
		hcontainer = get_node("Oeste/visibleHand/" + str(last_card.symbol))
	else:
		hcontainer = get_node("Este/visibleHand/" + str(last_card.symbol))
	pass
	for i : TextureRect in hcontainer.get_children():
		if i.name == card_name:
			i.queue_free()
			break

func _on_player_played(player_turn_ended : int) -> void:
	if player_turn_ended == 2 or player_turn_ended == 4:
		removeVisibleCar(player_turn_ended)
	var next_turn = player_turn_ended + 1
	cards_played += 1
	$Panel/Help.disabled = true
	if next_turn > 4:
		next_turn = 1
	if cards_played == 4:
		next_turn = await check_winner_of_round()
		cards_played = 0
	if $Rounds.get_child_count() == 13:
		$Panel2/VBoxContainer/HBoxContainer.visible = false
		$Panel2/VBoxContainer/HBoxContainer2/Label.text = ""
		if $Panel/WonCounter.text.to_int() >= dealAmount + 6:
			$Panel2/VBoxContainer/HBoxContainer2/Label2.text = "Se cumplio el contrato"
		else:
			$Panel2/VBoxContainer/HBoxContainer2/Label2.text = "Fallo el contrato"
		$Panel2/AnimationPlayer.play("simple_pop_up")
		return
	player_turn = next_turn
	match next_turn:
		1:
			$Panel/Help.disabled = false
			player1_turn.emit()
		2:
			player2_turn.emit()
		3:
			if player_won_bid % 2 == 1:
				$Panel/Help.disabled = false
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
					else:
						if winner_symbol != card_ui.symbol:
							continue
						else:
							if winner_value < card_ui.value:
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
		child.visible = false
		child.reparent(new_node)
	$Rounds.add_child(new_node)
	return winner

func _on_reset_pressed():
	get_tree().reload_current_scene()

func _on_return_pressed():
	Global.hands.clear()
	get_tree().change_scene_to_file("res://scenes/ui/configuration_deal.tscn")
