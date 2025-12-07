extends Node2D
## World Controller - Test/debug controls for gameplay
## Temporary script for testing the game loop

@onready var placement_system = $PlacementSystem
@onready var board = $Board
@onready var enemy_container = $EnemyContainer
@onready var tower_container = $TowerContainer
@onready var debug_label = $CanvasLayer/DebugLabel
@onready var path_manager = $PathManager
@onready var pause_menu = $CanvasLayer/PauseMenu
@onready var pause_sfx_slider: HSlider = $CanvasLayer/PauseMenu/VBoxContainer/SFX/HSlider
@onready var pause_bgm_slider: HSlider = $CanvasLayer/PauseMenu/VBoxContainer/BGM/HSlider
@onready var pause_main_menu_button: Button = $CanvasLayer/PauseMenu/VBoxContainer/MainMenu
@onready var pause_exit_button: Button = $CanvasLayer/PauseMenu/VBoxContainer/Exit

# Preload enemy scene
var enemy_scene = preload("res://scenes/enemies/basic_pawn.tscn")
const KING_SCENE := preload("res://scenes/towers/king.tscn")
const KING_FOOTPRINT_TILES := 2
var king_instance: Node2D = null


func _ready():
	# Ensure grid occupancy is clean when entering a world scene
	GridSystem.reset()

	if SoundManager and not SoundManager.is_music_playing():
		SoundManager.play_game_music()

	_sync_audio_sliders()

	if pause_menu:
		pause_menu.process_mode = Node.PROCESS_MODE_ALWAYS

	_connect_pause_menu_signals()

	EventBus.gold_changed.connect(_on_gold_changed)
	EventBus.wave_started.connect(_on_wave_started)
	EventBus.wave_completed.connect(_on_wave_completed)

	_update_debug_label()
	_spawn_king_base()

	if path_manager:
		WaveManager.initialize(path_manager, enemy_container)
		print("WaveManager initialized with PathManager")


func _input(event: InputEvent):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			_toggle_pause_menu()
			return

		if event.keycode == KEY_P:
			placement_system.start_placement("pawn", 1)

		elif event.keycode == KEY_N:
			placement_system.start_placement("knight", 5)

		elif event.keycode == KEY_B:
			placement_system.start_placement("bishop", 5)

		elif event.keycode == KEY_R:
			placement_system.start_placement("rook", 10)

		elif event.keycode == KEY_Q:
			placement_system.start_placement("queen", 25)

		elif event.keycode == KEY_K:
			_spawn_test_enemy()

		elif event.keycode == KEY_SPACE:
			if not WaveManager.is_wave_active():
				WaveManager.start_wave()
				print("Starting wave...")


func _spawn_test_enemy():
	if not enemy_scene:
		print("ERROR: basic_pawn.tscn not found!")
		return

	var enemy = enemy_scene.instantiate()
	enemy_container.add_child(enemy)

	# Set a simple path from top to bottom
	var path: Array[Vector2] = [
		Vector2(512, 100),
		Vector2(512, 300),
		Vector2(512, 500),
		Vector2(512, 700),
	]
	enemy.set_path(path)

	print("Enemy spawned at world pos: ", enemy.global_position)
	print("Enemy grid pos: ", GridSystem.world_to_grid(enemy.global_position))
	print("Spawned test enemy")


func _on_gold_changed(new_amount: int):
	_update_debug_label()


func _on_wave_started(wave_num: int):
	print("Wave ", wave_num, " started!")
	_update_debug_label()


func _on_wave_completed(wave_num: int):
	print("Wave ", wave_num, " completed!")
	_update_debug_label()


func _update_debug_label():
	if debug_label:
		var wave_status = ""
		if WaveManager.is_wave_active():
			wave_status = "Wave %d in progress..." % WaveManager.get_current_wave()
		else:
			wave_status = (
				"Press SPACE to start wave %d/%d"
				% [WaveManager.get_current_wave() + 1, WaveManager.max_waves]
			)

		debug_label.text = (
			"Gold: %d\n%s\nTowers:\nP = Pawn (Cost = 1)\nN = Knight (Cost = 5)\nB = Bishop (Cost = 5)\nR = Rook (Cost = 10)\nQ = Queen (Cost = 25)\n\nPress K to spawn test enemy\nRight-click to cancel placement\nPress ESC for options/pause"
			% [CurrencyManager.get_current_gold(), wave_status]
		)


func _spawn_king_base():
	if king_instance and is_instance_valid(king_instance):
		return

	if not tower_container:
		print("ERROR: TowerContainer not found! Cannot place King.")
		return

	var king = KING_SCENE.instantiate()
	var king_position = _get_board_center_world_position()
	if king is KingBase:
		king.footprint_tiles = KING_FOOTPRINT_TILES
	king.global_position = king_position

	tower_container.add_child(king)
	king_instance = king
	print("King placed at board center: ", king_position)


func _get_board_center_world_position() -> Vector2:
	if not board:
		return Vector2.ZERO

	var start_index = (
		board.chess_board_size + int(floor((board.cross_width - KING_FOOTPRINT_TILES) / 2.0))
	)
	var center_index = start_index + float(KING_FOOTPRINT_TILES) / 2.0
	var center = Vector2(center_index, center_index) * board.tile_size
	return center


func _toggle_pause_menu():
	if not pause_menu:
		return
	var showing = not pause_menu.visible
	pause_menu.visible = showing
	if showing:
		_sync_audio_sliders()
		get_tree().paused = true
	else:
		get_tree().paused = false


func _connect_pause_menu_signals():
	if not pause_menu:
		return

	var resume_button: Button = pause_menu.get_node_or_null("VBoxContainer/Resume")
	if resume_button:
		resume_button.pressed.connect(_on_pause_resume_pressed)
	if pause_main_menu_button:
		pause_main_menu_button.pressed.connect(_on_pause_main_menu_pressed)
	if pause_exit_button:
		pause_exit_button.pressed.connect(_on_pause_exit_pressed)

	if pause_sfx_slider:
		pause_sfx_slider.value_changed.connect(_on_pause_sfx_changed)
	if pause_bgm_slider:
		pause_bgm_slider.value_changed.connect(_on_pause_bgm_changed)


func _sync_audio_sliders():
	if not SoundManager:
		return
	if pause_sfx_slider:
		pause_sfx_slider.value = SoundManager.get_sfx_volume_db()
	if pause_bgm_slider:
		pause_bgm_slider.value = SoundManager.get_music_volume_db()


func _on_pause_resume_pressed():
	_toggle_pause_menu()


func _on_pause_main_menu_pressed():
	get_tree().paused = false
	if GameManager:
		GameManager.reset_game()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_pause_exit_pressed():
	get_tree().quit()


func _on_pause_sfx_changed(value: float):
	if SoundManager:
		SoundManager.set_sfx_volume_db(value)


func _on_pause_bgm_changed(value: float):
	if SoundManager:
		SoundManager.set_music_volume_db(value)
