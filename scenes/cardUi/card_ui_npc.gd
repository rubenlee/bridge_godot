class_name CardUINPC
extends Control

@onready var card_image = $CardImage

var player: int
var value: int
var symbol: int
var default_card: String = "card back/cardBackBlue"
var card_cover: String
var card_visible: bool = false
# Called when the node enters the scene tree for the first time.
func _ready():
	show_card()

func show_card():
	if card_visible:
		card_image.texture = load("res://Graphics/cards/" + card_cover + ".png")
	else: 
		card_image.texture = load("res://Graphics/cards/" + default_card + ".png")
