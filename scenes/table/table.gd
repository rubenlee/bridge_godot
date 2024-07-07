class_name Table
extends Node2D

@onready var normalCard: PackedScene = preload("res://scenes/cardUi/card_ui.tscn")
@onready var npcCard: PackedScene = preload("res://scenes/cardUi/card_ui_npc.tscn")

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
			 '311','112','211','411',
			 '312','112','212','412',
			 '313','113','213','413']
var cards_dealt = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func get_card():
	var choice = cards.pick_random()
	var x = cards.find(choice)
	cards.remove_at(x)
	cards_dealt.append(choice)
	return choice

func _on_button_pressed():
	for n in $Player1/Hand.get_children():
		$Player1/Hand.remove_child(n)
	for n in $Player2/Hand.get_children():
		$Player2/Hand.remove_child(n)
	for n in $Player3/Hand.get_children():
		$Player3/Hand.remove_child(n)
	for n in $Player4/Hand.get_children():
		$Player4/Hand.remove_child(n)
	var counter :int = 0
	for i in cards.size():
		var card : String = get_card()
		var value : int = card.substr(1).to_int()
		var symbol : int = card.substr(0,1).to_int()
		counter += 1	
		match counter:
			1:
				var new_card: CardUI = normalCard.instantiate()
				new_card.card_visible = true
				new_card.player = counter
				new_card.card_cover = card
				new_card.value = value
				new_card.symbol = symbol
				$Player1/Hand.add_card(new_card)
			2:
				var new_card: CardUINPC = npcCard.instantiate()
				new_card.player = counter
				new_card.card_cover = card
				new_card.value = value
				new_card.symbol = symbol
				$Player2/Hand.add_child(new_card)
			3:
				var new_card: CardUI = normalCard.instantiate()
				#new_card.card_visible = true
				new_card.player = counter
				new_card.card_cover = card
				new_card.value = value
				new_card.symbol = symbol
				$Player3/Hand.add_card(new_card)
			4:
				var new_card: CardUINPC = npcCard.instantiate()
				new_card.player = counter
				new_card.card_cover = card
				new_card.value = value
				new_card.symbol = symbol
				$Player4/Hand.add_child(new_card)
		counter %= 4
	$Player1/Hand.reconnect_signals()
	$Player3/Hand.reconnect_signals()
	cards = cards_dealt
	cards_dealt = []
