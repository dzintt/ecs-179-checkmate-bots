extends CanvasLayer


func _ready():
	# Freeze the game completely
	get_tree().paused = true
	process_mode = Node.PROCESS_MODE_ALWAYS


# Block all input EXCEPT for this menu
func _input(event):
	# Only handle input if it's not already handled by buttons
	if not event is InputEventMouseButton:
		get_viewport().set_input_as_handled()


func _on_restart_pressed() -> void:
	queue_free()
	# Unpause the game first
	get_tree().paused = false
	GameManager.reset_game()
	# Reload the current scene (restarts the game)
	get_tree().reload_current_scene()


func _on_return_to_main_menu_pressed() -> void:
	queue_free()
	# Unpause the game first
	get_tree().paused = false
	GameManager.reset_game()
	# Change to main menu scene (update path to your main menu)
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()
