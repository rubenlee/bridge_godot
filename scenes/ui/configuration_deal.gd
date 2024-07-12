class_name ConfigurationDeal
extends Node2D

var hands = []
var hands_on_text = []

func _on_add_pressed():
	var index = hands_on_text.size() + 1
	hands_on_text.append(str(index) + ": newValue")
	$HBoxContainer/eraseHandOption.add_item(str(index))
	$RichTextLabel.clear()
	for eachHand in hands_on_text:
		$RichTextLabel.add_text(eachHand + "\n")

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
