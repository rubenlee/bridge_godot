class_name  MainMenu
extends Node2D



func _on_quick_game_pressed():
	get_tree().change_scene_to_file("res://scenes/table/table.tscn")


func _on_quick_game_2_pressed():
	pass # Replace with function body.


func _on_quit_pressed():
	get_tree().quit()
