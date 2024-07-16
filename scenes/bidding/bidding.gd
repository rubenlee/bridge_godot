class_name Bidding
extends Control

var pass_counter = 0
var highest_vote = 0
var highest_vote_symbol = 0
signal biddings_over(player_won_bid : int, symbol : int, deal_amount : int)

func _ready():
	for child : Button in $bid_grid.get_children():
		child.pressed.connect(_on_bid_pressed.bind(child))
	for child : Button in $bid_rest.get_children():
		child.pressed.connect(_on_bid_pressed.bind(child))

func set_first_turn(turn : int):
	for i in range(turn):
		add_blank()
		
func deal_pressed(button_name : String):
	if button_name ==  "pass":
		$bid_rest/Button36.pressed.emit()
	else:
		for child in $bid_grid.get_children():
			var button : Button = child as Button
			if button.name == button_name:
				button.pressed.emit()
	
func _on_bid_pressed(button : Button):
	var new_label : RichTextLabel = $bid_result_grid/Label.duplicate()
	var value_label = button.text.to_int()
	new_label.name = button.name
	new_label.text = button.text 
	$bid_result_grid.add_child(new_label)
	if button.text == "PASAR":
		pass_counter += 1
		if pass_counter == 3:
			deal_done()
		return
	if button.icon != null:
		new_label.text += "[img=30x30]" + button.icon.resource_path + "[/img]"
	highest_vote_symbol = get_symbol_value(button.name.substr(1))
	highest_vote = value_label
	for child : Button in $bid_grid.get_children():
		var value_button_temp = child.text.to_int()
		if value_label < value_button_temp:
			break
		elif value_label > value_button_temp:
			child.disabled = true
			continue
		if highest_vote_symbol >= get_symbol_value(child.name.substr(1)):
			child.disabled = true
	
func deal_done():
	var last_deal : RichTextLabel = $bid_result_grid.get_child($bid_result_grid.get_child_count() - 4)
	var deal_amount : int = last_deal.name.substr(0,1).to_int()
	var symbol : int = get_symbol_value(last_deal.name.substr(1)) % 5
	var player : int = 1
	player += ($bid_result_grid.get_child_count() - 2) % 4
	biddings_over.emit(player, symbol, deal_amount)
	self.queue_free()

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
