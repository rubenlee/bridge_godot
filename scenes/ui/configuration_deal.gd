class_name ConfigurationDeal
extends Node2D

var hands = []
var hands_on_text = []

func _on_add_pressed():
	var new_hbox : HBoxContainer = HBoxContainer.new()
	var new_button : Button = Button.new()
	var new_label : Label = Label.new()
	var default_theme : Theme = load("res://default.tres")
	var label_string : String = "R:" + $PanelContainer/HBoxContainer5/OptionButton2.text + "|J:" + $PanelContainer/HBoxContainer/OptionButton2.text
	label_string += "|" + $PanelContainer/Mano.text + ":PH:" + str($PanelContainer/honorPoint/VBoxContainer/HBoxContainer/value.value)
	if $PanelContainer/honorPoint/VBoxContainer/HBoxContainer/value.value != $PanelContainer/honorPoint/VBoxContainer/HBoxContainer/value2.value:
		label_string += "-" + str($PanelContainer/honorPoint/VBoxContainer/HBoxContainer/value2.value)
	label_string += "|" + $PanelContainer/Mano2.text + ":PH:" + str($PanelContainer/honorPoint2/VBoxContainer2/HBoxContainer/value.value)
	if $PanelContainer/honorPoint2/VBoxContainer2/HBoxContainer/value.value != $PanelContainer/honorPoint2/VBoxContainer2/HBoxContainer/value2.value:
		label_string += "-" + str($PanelContainer/honorPoint2/VBoxContainer2/HBoxContainer/value2.value)
	new_button.text = "X"
	new_hbox.add_child(new_button)
	new_hbox.add_child(new_label)
	$posiblesGames.add_child(new_hbox)
	new_button.pressed.connect(func(): new_button.get_parent().queue_free())
	new_button.theme = load("res://default.tres")
	new_label.set("theme_override_font_sizes/font_size", 14)
	new_label.text = label_string
	'''
	var index = hands_on_text.size() + 1
	hands_on_text.append(str(index) + ": newValue")
	$HBoxContainer/eraseHandOption.add_item(str(index))
	$RichTextLabel.clear()
	for eachHand in hands_on_text:
		$RichTextLabel.add_text(eachHand + "\n")
	'''

func _on_start_pressed():
	var table_scene = preload("res://scenes/table/table.tscn").instantiate()
	table_scene.dealAmount = 2
	get_tree().get_root().add_child(table_scene)
	self.queue_free()

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
			$PanelContainer/Mano2.text = "Sur"
		1:
			$PanelContainer/Mano.text = "Este"
			$PanelContainer/Mano2.text = "Oeste"


func _on_deal_selected(index):
	var visible_distribution = true
	if index == 0:
		visible_distribution = false
	$PanelContainer/distributionPoint.visible = visible_distribution
	$PanelContainer/distributionPoint2.visible = visible_distribution


func _on_preset_button_pressed():
	if $VBoxContainer/presetOption.get_selected_id() == -1:
		pass
	elif $VBoxContainer/presetOption.get_selected_id() < 4:
		$PanelContainer/HBoxContainer/OptionButton2.select(0)
		_on_deal_selected(0)
	match $VBoxContainer/presetOption.get_selected_id():
		0:
			$PanelContainer/honorPoint/VBoxContainer/HBoxContainer/value.value = 15
			$PanelContainer/honorPoint/VBoxContainer/HBoxContainer/value2.value = randi_range(15,17)
			$PanelContainer/honorPoint2/VBoxContainer2/HBoxContainer/value.value = 0
			$PanelContainer/honorPoint2/VBoxContainer2/HBoxContainer/value2.value = randi_range(0,7)
		1:
			$PanelContainer/honorPoint/VBoxContainer/HBoxContainer/value.value = 15
			$PanelContainer/honorPoint/VBoxContainer/HBoxContainer/value2.value = randi_range(15,16)
			$PanelContainer/honorPoint2/VBoxContainer2/HBoxContainer/value.value = 8
			$PanelContainer/honorPoint2/VBoxContainer2/HBoxContainer/value2.value = randi_range(8,9)
		2:
			$PanelContainer/honorPoint/VBoxContainer/HBoxContainer/value.value = 15
			$PanelContainer/honorPoint/VBoxContainer/HBoxContainer/value2.value = randi_range(15,17)
			$PanelContainer/honorPoint2/VBoxContainer2/HBoxContainer/value.value = 10
			$PanelContainer/honorPoint2/VBoxContainer2/HBoxContainer/value2.value = randi_range(10,15)
			pass
		3:
			pass
