extends Control

@onready var dialogue_label: Label = $VBoxContainer/DialogueLabel
@onready var next_button: Button = $VBoxContainer/NextButton

var lines: Array[String] = [
	"Welcome, Commander!\n\nI'll walk you through how to defend the King.",
	"Gold:\n- You start with some gold.\n- Spend gold to buy towers.\n\nPress SPACE to start each wave.",
	"Towers:\n" +
	"P = Pawn  (Cost 1) – Cheap, hits up to 2 tiles away in a plus shape (up/down/left/right).\n" +
	"N = Knight (Cost 5) – L-shaped hits like a chess knight, strong burst damage.\n" +
	"B = Bishop (Cost 5) – Shoots projectiles along diagonals across the board.\n" +
	"R = Rook   (Cost 10) – Shoots projectiles in straight lanes (up/down/left/right).\n" +
	"Q = Queen  (Cost 25) – Fires fast projectiles in all directions, best coverage and damage.\n" +
	"The King is your base. If it dies, you lose.",
	"Enemies:\n- Basic Pawn: slow and weak.\n- Loot Runner: very fast, low HP, gives extra gold.\n- Shield Guard: slow, high HP, soaks damage.\n- Caster: medium HP, higher damage to the king.\n- Bomber: speeds up near the king and explodes for big damage.",
	"That’s it! Defend the King and survive all waves!"
]

var current_index: int = 0

func _ready() -> void:
	_update_line()
	next_button.pressed.connect(_on_next_button_pressed)

func _on_next_button_pressed() -> void:
	current_index += 1

	# If we've gone past the last line, actually go back to main menu
	if current_index >= lines.size():
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	else:
		_update_line()

func _update_line() -> void:
	dialogue_label.text = lines[current_index]

	if current_index == lines.size() - 1:
		next_button.text = "Back to Main Menu"
	else:
		next_button.text = "Next"
