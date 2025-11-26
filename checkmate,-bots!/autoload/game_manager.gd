extends Node

## Game Manager - Core game state and flow control
## Singleton accessible via GameManager
## Manages game state machine, win/lose conditions, scene transitions
var game_over_menu_scene = preload("res://scenes/game_over_menu.tscn")
var game_over_menu_instance = null

enum GameState {
	MENU,
	PLAYING,
	PAUSED,
	WAVE_ACTIVE,
	WAVE_COMPLETE,
	GAME_OVER,
	VICTORY
}

var current_state: GameState = GameState.MENU

# Signals
signal game_state_changed(new_state: GameState)
signal game_started()
signal game_paused()
signal game_resumed()
signal game_over(victory: bool)

func _ready():
	print("GameManager initialized")

## Reset all game state
func reset_game():
	# Reset game manager state
	current_state = GameState.MENU
	game_over_menu_instance = null
	
	# Reset currency system
	if CurrencyManager:
		CurrencyManager.reset_gold()
	
	# Reset wave manager
	if WaveManager:
		WaveManager.reset_waves()
	
	print("Game state reset")

## Start a new game
func start_game():
	reset_game()
	current_state = GameState.PLAYING
	game_state_changed.emit(current_state)
	game_started.emit()
	print("Game started")
	# TODO: Initialize game state, reset currency, reset waves


## Pause the game
func pause_game():
	if current_state == GameState.PLAYING or current_state == GameState.WAVE_ACTIVE:
		current_state = GameState.PAUSED
		game_state_changed.emit(current_state)
		game_paused.emit()
		get_tree().paused = true
		print("Game paused")


## Resume the game
func resume_game():
	if current_state == GameState.PAUSED:
		current_state = GameState.PLAYING
		game_state_changed.emit(current_state)
		game_resumed.emit()
		get_tree().paused = false
		print("Game resumed")


## End the game (victory or defeat)
func end_game(victory: bool):
	if game_over_menu_instance:
		return
	
	current_state = GameState.VICTORY if victory else GameState.GAME_OVER
	game_state_changed.emit(current_state)
	game_over.emit(victory)
	
	game_over_menu_instance = game_over_menu_scene.instantiate()
	get_tree().root.add_child(game_over_menu_instance)
	
	print("Game over - Victory: ", victory)
	# TODO: Show game over/victory screen
	


## Check if all waves are completed
func check_win_condition():
	# TODO: Implement - check with WaveManager if all waves complete
	pass


## Check if King is destroyed
func check_lose_condition():
	# TODO: Implement - called when King health reaches 0
	pass
