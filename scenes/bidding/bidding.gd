class_name Bidding
extends Control

var pass_counter = 0
var highest_vote = 0
var highest_vote_symbol = -1
var highest_player_vote = -1
var dealt = false
signal biddings_over(player_won_bid : int, symbol : int, deal_amount : int)

func _ready():
	for child : Button in $bid_grid.get_children():
		child.pressed.connect(_on_bid_pressed.bind(child))
	for child : Button in $bid_rest.get_children():
		child.pressed.connect(_on_bid_pressed.bind(child))

func toggle_buttons(disable : bool) -> void:
	for child in $bid_grid.get_children():
		child.disabled = disable
	disable_already_under_buttons()
	for child in $bid_rest.get_children():
		child.disabled = disable

func disable_already_under_buttons() -> void:
	for child : Button in $bid_grid.get_children():
		var value_button_temp = child.text.to_int()
		if highest_vote < value_button_temp:
			break
		elif highest_vote > value_button_temp:
			child.disabled = true
			continue
		if highest_vote_symbol >= get_symbol_value(child.name.substr(1)):
			child.disabled = true

func set_first_turn(turn : int) -> void:
	for i in range(turn):
		add_blank()
		
func deal_pressed(button_name : String) -> void:
	if dealt == true:
		return
	if button_name ==  "pass":
		$bid_rest/Button36.pressed.emit()
	else:
		for child in $bid_grid.get_children():
			var button : Button = child as Button
			if button.name == button_name:
				button.pressed.emit()
	
func _on_bid_pressed(button : Button):
	if dealt == true:
		return
	var new_label : RichTextLabel = $bid_result_grid/Label.duplicate()
	var value_label = button.text.to_int()
	new_label.name = button.name
	new_label.text = button.text 
	$bid_result_grid.add_child(new_label)
	var player = $bid_result_grid.get_child_count() % 4
	if player == 1:
		var root := get_tree().get_first_node_in_group("root") as Table
		root._on_bidding_deal(player, button.name)
	if button.text == "PASAR":
		pass_counter += 1
		if pass_counter == 3:
			deal_done()
		return
	pass_counter = 0
	if button.icon != null:
		new_label.text += "[img=30x30]" + button.icon.resource_path + "[/img]"
	var temp_vote_symbol = get_symbol_value(button.name.substr(1))	
	highest_vote = value_label
	if temp_vote_symbol != highest_vote_symbol and highest_player_vote % 2 != player % 2:
		highest_vote_symbol = temp_vote_symbol
		highest_player_vote = player
	
func deal_done():
	dealt = true
	biddings_over.emit(highest_player_vote, highest_vote_symbol, highest_vote)

func get_symbol_value(symbol_str : String) -> int:
	match symbol_str:
		"C":
			return 1
		"D":
			return 2
		"H":
			return 3
		"S":
			return 4
		"NT":
			return 5
		_:
			return 0

func add_blank() -> void:
	var new_label : RichTextLabel = $bid_result_grid/Label.duplicate()
	new_label.text = ""
	$bid_result_grid.add_child(new_label)
