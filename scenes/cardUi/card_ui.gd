class_name CardUI
extends Control

signal reparent_requested(which_card_ui: CardUI)
signal card_played()

@onready var color: ColorRect = $Color
@onready var card_state_machine: CardStateMachine = $CardStateMachine as CardStateMachine
@onready var drop_point_detector = $DropPointDetector
@onready var targets: Array[Node] = []
@onready var card_image = $CardImage

var player: int
var value: int
var symbol: int
var default_card: String = "card back/cardBackBlue"
var card_cover: String
var card_visible: bool = false
var tween: Tween

func _ready() -> void:
	card_state_machine.init(self)
	show_card()
	
func _input(event: InputEvent) -> void:
	card_state_machine.on_input(event)
	
func _on_gui_input(event: InputEvent) -> void:
	card_state_machine.on_gui_input(event)
	
func _on_mouse_entered() -> void:
	card_state_machine.on_mouse_entered()
	
func _on_mouse_exited() -> void:
	card_state_machine.on_mouse_exited()

func _on_drop_point_detector_area_entered(area):
	if not targets.has(area):
		targets.append(area)

func _on_drop_point_detector_area_exited(area):
	targets.erase(area)

func show_card():
	if card_visible:
		card_image.texture = load("res://Graphics/cards/" + card_cover + ".png")
	else: 
		card_image.texture = load("res://Graphics/cards/" + default_card + ".png")
		
func card_clicked():
	self.color.visible = false
	self.card_visible = true
	show_card()
	tween = create_tween()
	var newPosition = self.get_parent().positionInTable
	var ui_layer := get_tree().get_first_node_in_group("table")
	if ui_layer:
		self.reparent(ui_layer)
	tween.tween_property(self, "global_position", newPosition , 0.75)
	#tween.tween_property(self, "rotation", 0 , 0.5)
	await tween.finished
	self.card_played.emit()
