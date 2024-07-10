class_name CardUI
extends Control

signal reparent_requested(which_card_ui: CardUI)
signal card_played()

@onready var color_2: ColorRect = $Color2
@onready var color: ColorRect = $Color
@onready var card_image = $CardImage

var player: int
var value: int
var symbol: int
var default_card: String = "card back/cardBackBlue"
var card_cover: String
var card_visible: bool = false

func _ready() -> void:
	show_card()
	
func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_mouse") and (color.visible or color_2.visible):
		card_clicked()
	
func show_card():
	if card_visible:
		card_image.texture = load("res://Graphics/cards/" + card_cover + ".png")
	else: 
		card_image.texture = load("res://Graphics/cards/" + default_card + ".png")
		
func card_clicked():
	var parent : Hand = self.get_parent()
	parent.disable_visible_for_cards()
	self.card_visible = true
	show_card()
	var tween: Tween = create_tween()
	var newPosition = parent.positionInTable
	if parent.playerInd == 2 or parent.playerInd == 4:
		tween.tween_property(self, "global_position", parent.positionToMoveToTable , 0.1)
	var ui_layer := get_tree().get_first_node_in_group("table")
	if ui_layer:
		self.reparent(ui_layer)
	tween.tween_property(self, "global_position", newPosition , 0.75)
	await tween.finished
	self.card_played.emit()
