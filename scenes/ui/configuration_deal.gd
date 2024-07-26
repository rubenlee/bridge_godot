class_name ConfigurationDeal
extends Node2D

const TABLE = preload("res://scenes/table/table.tscn")

func _on_ready():
	pass

func add_new_hand():
	var new_hbox : HBoxContainer = HBoxContainer.new()
	var new_button : Button = Button.new()
	var new_label : Label = Label.new()
	var default_theme : Theme = load("res://default.tres")
	var label_string : String = "R:" + $PanelContainer/HBoxContainer5/OptionButton2.text + "|J:" + $PanelContainer/HBoxContainer/OptionButton2.text
	label_string += "|" + $PanelContainer/Mano.text + ":PH:" + str($PanelContainer/HBoxContainer2/honorPoint/VBoxContainer/HBoxContainer/value.value)
	if $PanelContainer/HBoxContainer2/honorPoint/VBoxContainer/HBoxContainer/value.value != $PanelContainer/HBoxContainer2/honorPoint/VBoxContainer/HBoxContainer/value2.value:
		label_string += "-" + str($PanelContainer/HBoxContainer2/honorPoint/VBoxContainer/HBoxContainer/value2.value)
	label_string += "|" + $PanelContainer/Mano2.text + ":PH:" + str($PanelContainer/HBoxContainer3/honorPoint2/VBoxContainer2/HBoxContainer/value.value)
	if $PanelContainer/HBoxContainer3/honorPoint2/VBoxContainer2/HBoxContainer/value.value != $PanelContainer/HBoxContainer3/honorPoint2/VBoxContainer2/HBoxContainer/value2.value:
		label_string += "-" + str($PanelContainer/HBoxContainer3/honorPoint2/VBoxContainer2/HBoxContainer/value2.value)
	new_button.text = "X"
	new_hbox.add_child(new_button)
	new_hbox.add_child(new_label)
	$posiblesGames.add_child(new_hbox)
	new_button.pressed.connect(func(): 
		Global.hands.remove_at(new_button.get_parent().get_index())
		new_button.get_parent().queue_free())
	new_button.theme = default_theme
	new_label.theme = default_theme
	new_label.set("theme_override_font_sizes/font_size", 14)
	new_label.text = label_string

func _on_add_pressed():
	var new_hand = {}
	add_new_hand()
	new_hand["Dealer"] = $PanelContainer/HBoxContainer5/OptionButton2.get_selected_id()
	new_hand["AffectedHands"] = $PanelContainer/HBoxContainer4/OptionButton2.get_selected_id()
	new_hand["Game"] = $PanelContainer/HBoxContainer/OptionButton2.get_selected_id() 
	new_hand["mainMinHonorPoints"] = $PanelContainer/HBoxContainer2/honorPoint/VBoxContainer/HBoxContainer/value.value
	new_hand["mainMaxHonorPoints"] = $PanelContainer/HBoxContainer2/honorPoint/VBoxContainer/HBoxContainer/value2.value
	new_hand["mainMinDistributionPoints"] = $PanelContainer/HBoxContainer2/distributionPoint/VBoxContainer2/HBoxContainer/value.value
	new_hand["mainMaxDistributionPoints"] =  $PanelContainer/HBoxContainer2/distributionPoint/VBoxContainer2/HBoxContainer/value2.value
	new_hand["offMinHonorPoints"] = $PanelContainer/HBoxContainer3/honorPoint2/VBoxContainer2/HBoxContainer/value.value
	new_hand["offMaxHonorPoints"] = $PanelContainer/HBoxContainer3/honorPoint2/VBoxContainer2/HBoxContainer/value2.value
	new_hand["offMinDistributionPoints"] = $PanelContainer/HBoxContainer3/distributionPoint2/VBoxContainer2/HBoxContainer/value.value
	new_hand["offMaxDistributionPoints"] = $PanelContainer/HBoxContainer3/distributionPoint2/VBoxContainer2/HBoxContainer/value2.value
	new_hand["inverse"] = false
	if new_hand["mainMaxHonorPoints"] < new_hand["offMaxHonorPoints"]:
		new_hand["inverse"] = true
	Global.hands.append(new_hand)

func _on_start_pressed():
	get_tree().change_scene_to_packed(TABLE)

func _on_import_pressed():
	$FileDialog.visible = true

func _on_export_pressed():
	pass # Replace with function body.

func _on_return_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_erase_hand_pressed():
	pass

func _on_option_button_2_item_selected(index) -> void:
	match index:
		0:
			$PanelContainer/Mano.text = "Norte"
			$PanelContainer/Mano2.text = "Sur (jugador)"
		1:
			$PanelContainer/Mano.text = "Este"
			$PanelContainer/Mano2.text = "Oeste"


func _on_deal_selected(index):
	var visible_distribution = true
	match index:
		0:
			visible_distribution = false
		_:
			pass
	$PanelContainer/HBoxContainer2/distributionPoint.visible = visible_distribution
	$PanelContainer/HBoxContainer3/distributionPoint2.visible = visible_distribution


func _on_preset_button_pressed():
	if $VBoxContainer/presetOption.get_selected_id() == -1:
		pass
	elif $VBoxContainer/presetOption.get_selected_id() < 4:
		$PanelContainer/HBoxContainer/OptionButton2.select(0)
		_on_deal_selected(0)
	match $VBoxContainer/presetOption.get_selected_id():
		0:
			$PanelContainer/HBoxContainer3/honorPoint2/VBoxContainer2/HBoxContainer/value.value = 15
			$PanelContainer/HBoxContainer3/honorPoint2/VBoxContainer2/HBoxContainer/value2.value = 17
			$PanelContainer/HBoxContainer2/honorPoint/VBoxContainer/HBoxContainer/value.value = 0
			$PanelContainer/HBoxContainer2/honorPoint/VBoxContainer/HBoxContainer/value2.value = 7
		1:
			$PanelContainer/HBoxContainer3/honorPoint2/VBoxContainer2/HBoxContainer/value.value = 15
			$PanelContainer/HBoxContainer3/honorPoint2/VBoxContainer2/HBoxContainer/value2.value = 16
			$PanelContainer/HBoxContainer2/honorPoint/VBoxContainer/HBoxContainer/value.value = 8
			$PanelContainer/HBoxContainer2/honorPoint/VBoxContainer/HBoxContainer/value2.value = 9
		2:
			$PanelContainer/HBoxContainer3/honorPoint2/VBoxContainer2/HBoxContainer/value.value = 15
			$PanelContainer/HBoxContainer3/honorPoint2/VBoxContainer2/HBoxContainer/value2.value = 17
			$PanelContainer/HBoxContainer2/honorPoint/VBoxContainer/HBoxContainer/value.value = 10
			$PanelContainer/HBoxContainer2/honorPoint/VBoxContainer/HBoxContainer/value2.value = 15
			pass
		3:
			$PanelContainer/HBoxContainer3/honorPoint2/VBoxContainer2/HBoxContainer/value.value = 12
			$PanelContainer/HBoxContainer3/honorPoint2/VBoxContainer2/HBoxContainer/value2.value = 19
			$PanelContainer/HBoxContainer2/honorPoint/VBoxContainer/HBoxContainer/value.value = 0
			$PanelContainer/HBoxContainer2/honorPoint/VBoxContainer/HBoxContainer/value2.value = 5
			$PanelContainer/HBoxContainer3/distributionPoint2/VBoxContainer2/HBoxContainer/value2.value = 1
			_on_deal_selected(3)
			$PanelContainer/HBoxContainer/OptionButton2.select(3)
			pass
