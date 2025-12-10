extends Control

@onready var dialogue_label: Label = $VBoxContainer/DialogueLabel
@onready var next_button: Button = $VBoxContainer/NextButton

var lines: Array[String] = [
	"Welcome, Commander!\n\nGoal: keep the King alive.\nIf the King dies, you lose.",
	"Game flow:\n- Place towers on empty tiles.\n- Enemies walk toward the King.\n- Press SPACE to start each wave.",
	"Gold:\n- You start with some gold.\n- Killing enemies gives more.\n- Spend gold between waves to buy towers.",
	(
		"Towers:\n"
		+ "P (1): cheap, short range.\n"
		+ "N (5): L-shape, strong hit.\n"
		+ "B (5): long diagonal shots.\n"
		+ "R (10): long straight shots.\n"
		+ "Q (25): big range, high damage."
	),
	(
		"Enemies:\n"
		+ "Pawn: slow, weak.\n"
		+ "Loot Runner: very fast, extra gold.\n"
		+ "Shield: very tanky.\n"
		+ "Caster: hurts the King more.\n"
		+ "Bomber: speeds up and explodes."
	),
	"Tip:\nSome towers work better on certain enemies.\nExperiment with setups.\n\nGood luck defending the King!"
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
