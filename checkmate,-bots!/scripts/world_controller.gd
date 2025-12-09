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
@onready var king_health_hud = $CanvasLayer/KingHealthHUD
var move_mode: bool = false
var move_selected: Tower = null
var move_valid_tiles: Array[Vector2i] = []
var move_overlay: Node2D
var _move_pool: Array[ColorRect] = []
const MOVE_COLOR := Color(0.1, 0.9, 0.2, 0.28)

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

	move_overlay = Node2D.new()
	move_overlay.name = "MoveOverlay"
	add_child(move_overlay)

	_update_debug_label()
	_spawn_king_base()
	_init_king_health_hud()

	if path_manager:
		WaveManager.initialize(path_manager, enemy_container)
		print("WaveManager initialized with PathManager")


func _input(event: InputEvent):
	if move_mode:
		if event is InputEventMouseButton and event.pressed:
			if event.button_index == MOUSE_BUTTON_RIGHT:
				if move_selected != null:
					move_selected = null
					move_valid_tiles.clear()
					_clear_move_overlay()
					_update_debug_label()
				else:
					_exit_move_mode()
				return
			if event.button_index == MOUSE_BUTTON_LEFT:
				_handle_move_click()
				return
		if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
			_exit_move_mode()
			if not WaveManager.is_wave_active():
				WaveManager.start_wave()
			return

	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			_toggle_pause_menu()
			return

		if event.keycode == KEY_P:
			placement_system.start_placement("pawn", 1)

		elif event.keycode == KEY_K:
			placement_system.start_placement("knight", 3)

		elif event.keycode == KEY_B:
			placement_system.start_placement("bishop", 3)

		elif event.keycode == KEY_R:
			placement_system.start_placement("rook", 5)

		elif event.keycode == KEY_Q:
			placement_system.start_placement("queen", 9)

		elif event.keycode == KEY_SPACE:
			if placement_system and placement_system.has_method("cancel_placement"):
				placement_system.cancel_placement()
			if not WaveManager.is_wave_active():
				WaveManager.start_wave()
				print("Starting wave...")


func _on_gold_changed(_new_amount: int):
	_update_debug_label()


func _on_wave_started(wave_num: int):
	print("Wave ", wave_num, " started!")
	_exit_move_mode()
	_update_debug_label()


func _on_wave_completed(wave_num: int):
	print("Wave ", wave_num, " completed!")
	_enter_move_mode()
	_update_debug_label()


func _update_debug_label():
	if debug_label:
		var wave_status = ""
		if WaveManager.is_wave_active():
			wave_status = "Wave %d in progress..." % WaveManager.get_current_wave()
		elif WaveManager.get_current_wave() >= WaveManager.max_waves:
			return
		else:
			var next_wave := WaveManager.get_current_wave() + 1
			var summary := (
				WaveManager.get_wave_summary(next_wave)
				if WaveManager.has_method("get_wave_summary")
				else ""
			)
			if move_mode:
				wave_status = (
					"Move 1 tower (click tower, then tile)\nPress SPACE to start wave %d/%d\nNext: %s"
					% [next_wave, WaveManager.max_waves, summary]
				)
			else:
				wave_status = (
					"Press SPACE to start wave %d/%d\nNext: %s"
					% [next_wave, WaveManager.max_waves, summary]
				)

		debug_label.text = (
			"Gold: %d\n%s\nRight-click to cancel placement\nPress ESC for options/pause"
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


func _init_king_health_hud():
	if king_health_hud and king_instance and king_instance is KingBase:
		king_health_hud.initialize(king_instance.current_health, king_instance.max_health)


func _get_board_center_world_position() -> Vector2:
	if not board:
		return Vector2.ZERO

	var start_index = (
		board.chess_board_size + int(floor((board.cross_width - KING_FOOTPRINT_TILES) / 2.0))
	)
	var center_index = start_index + float(KING_FOOTPRINT_TILES) / 2.0
	var center = Vector2(center_index, center_index) * board.tile_size
	return center


func _enter_move_mode():
	if move_mode:
		return
	if tower_container == null or tower_container.get_child_count() == 0:
		return
	move_mode = true
	move_selected = null
	move_valid_tiles.clear()
	_clear_move_overlay()
	_update_debug_label()
	print("Move mode: select a tower, then a highlighted tile.")


func _exit_move_mode():
	if not move_mode:
		return
	move_mode = false
	move_selected = null
	move_valid_tiles.clear()
	_clear_move_overlay()
	_update_debug_label()


func _handle_move_click():
	var cam := get_viewport().get_camera_2d()
	if cam == null:
		return
	var world_pos = cam.get_global_mouse_position()
	var grid_pos = GridSystem.world_to_grid(world_pos)

	if move_selected == null:
		var tower := _tower_at_grid(grid_pos)
		if tower:
			move_selected = tower
			move_valid_tiles = _compute_move_tiles(tower)
			_show_move_tiles(move_valid_tiles)
		return

	# Already selected a tower; attempt move
	if move_valid_tiles.has(grid_pos):
		_move_selected_to(grid_pos)
		_exit_move_mode()
		return

	# Reselect another tower if clicked
	var new_tower := _tower_at_grid(grid_pos)
	if new_tower:
		move_selected = new_tower
		move_valid_tiles = _compute_move_tiles(new_tower)
		_show_move_tiles(move_valid_tiles)


func _tower_at_grid(grid_pos: Vector2i) -> Tower:
	if tower_container == null:
		return null
	for child in tower_container.get_children():
		if child is Tower:
			var t: Tower = child
			if t.grid_position == grid_pos:
				return t
	return null


func _compute_move_tiles(tower: Tower) -> Array[Vector2i]:
	var tiles: Array[Vector2i] = []
	if not tower:
		return tiles
	var pattern := tower.get_attack_pattern()
	for offset in pattern:
		var target := tower.grid_position + offset
		if not GridSystem.is_within_board(target):
			continue
		if GridSystem.is_cross_tile(target):
			continue
		if GridSystem.is_tile_occupied(target) and target != tower.grid_position:
			continue
		tiles.append(target)
	return tiles


func _move_selected_to(grid_pos: Vector2i):
	if move_selected == null:
		return
	var old_pos := move_selected.grid_position
	GridSystem.release_tile(old_pos)
	GridSystem.occupy_tile(grid_pos)
	move_selected.grid_position = grid_pos
	move_selected.global_position = GridSystem.grid_to_world(grid_pos)
	# Keep tower's rest position in sync so bounce/attacks don't snap back.
	move_selected._rest_position = move_selected.position
	print("Moved ", move_selected.tower_name, " from ", old_pos, " to ", grid_pos)


func _show_move_tiles(tiles: Array[Vector2i]):
	_ensure_move_overlay_pool(tiles.size())
	var tile_size = Vector2(GridSystem.TILE_SIZE, GridSystem.TILE_SIZE)
	var used := 0
	for pos in tiles:
		if used >= _move_pool.size():
			break
		var rect := _move_pool[used]
		used += 1
		rect.visible = true
		rect.size = tile_size
		rect.position = GridSystem.grid_to_world(pos) - tile_size / 2.0
		rect.color = MOVE_COLOR
	for i in range(used, _move_pool.size()):
		_move_pool[i].visible = false


func _clear_move_overlay():
	for rect in _move_pool:
		rect.visible = false


func _ensure_move_overlay_pool(count: int):
	while _move_pool.size() < count:
		var rect = ColorRect.new()
		rect.visible = false
		rect.size = Vector2(GridSystem.TILE_SIZE, GridSystem.TILE_SIZE)
		rect.color = MOVE_COLOR
		if move_overlay:
			move_overlay.add_child(rect)
		_move_pool.append(rect)


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

	if SoundManager:
		(
			SoundManager
			. connect_button_sounds(
				[
					resume_button,
					pause_main_menu_button,
					pause_exit_button,
				]
			)
		)

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
