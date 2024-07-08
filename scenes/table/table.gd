class_name Table
extends Node2D

@onready var normalCard: PackedScene = preload("res://scenes/cardUi/card_ui.tscn")
@onready var npcCard: PackedScene = preload("res://scenes/cardUi/card_ui_npc.tscn")

enum NOTRUMPHHANDS {BALANCED, ONESEMIFAIL, UNBALANCED}

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
# Called when the node enters the scene tree for the first time.
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
				$Player2/Hand.add_child(card)
			3:
				#card.card_visible = true
				card.player = counter
				$Player3/Hand.add_card(card)
			4:
				card.player = counter
				$Player4/Hand.add_child(card)
		counter %= 4
	$Player1/Hand.reconnect_signals()
	$Player3/Hand.reconnect_signals()
	print($Player1/Hand.get_child_count(), "-", $Player3/Hand.get_child_count())
	print($Player2/Hand.get_child_count(), "-", $Player4/Hand.get_child_count())

func _on_help_pressed():
	pass # Replace with function body.

func _on_deal_no_triumph_pressed():
	notrumph_main_hand()
	notrumph_off_hand()
	_on_button_pressed()

func _on_deal_random_pressed():
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
				$Player2/Hand.add_child(card)
			3:
				card.card_visible = true
				card.player = counter
				$Player3/Hand.add_card(card)
			4:
				card.player = counter
				$Player4/Hand.add_child(card)
		counter %= 4
	$Player1/Hand.reconnect_signals()
	$Player3/Hand.reconnect_signals()

func notrumph_main_hand() -> void:
	#var type = NOTRUMPHHANDS.values().pick_random()
	var type = NOTRUMPHHANDS.BALANCED
	var main_hand_value = randi_range(15,17)
	var type_counter = [0,0,0,0]
	var acumulated_value = 0
	match type:
		NOTRUMPHHANDS.BALANCED:
			var four_in_one = false
			while true:
				var rand_type = randi_range(1,4)
				var rand_value
				if(main_hand_value == acumulated_value):
					break
				elif(main_hand_value - acumulated_value >= 5):
					rand_value = randi_range(11, 14)
				else:
					rand_value = randi_range(11, 10 + (main_hand_value-acumulated_value))
				if type_counter[rand_type - 1] > 3:
					continue
				if cardsGot.has((rand_type * 100) + rand_value):
					continue
				acumulated_value += rand_value % 10
				type_counter[rand_type - 1] += 1
				search_card(rand_type, rand_value, 1)
				cardsGot[(rand_type * 100) + rand_value] = 0
			for i in type_counter.size():
				var one_more = randi() % 2 == 0
				if not four_in_one and i == type_counter.size()-1:
					one_more = true
				var max = 3
				if not one_more and type_counter[i] == max:
					continue
				if four_in_one:
					one_more = false
				if not four_in_one and one_more:
					max += 1
					four_in_one = true
				while type_counter[i] < max:
					var rand_value = randi_range(2, 10)
					if cardsGot.has(((i + 1) * 100) + rand_value):
						continue
					search_card((i + 1), rand_value, 1)
					cardsGot[((i + 1) * 100) + rand_value] = 0
					type_counter[i] += 1
		NOTRUMPHHANDS.ONESEMIFAIL:
			pass
		NOTRUMPHHANDS.UNBALANCED:
			pass

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
