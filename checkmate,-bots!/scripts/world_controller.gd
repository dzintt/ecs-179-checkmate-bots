extends Node2D

## World Controller - Test/debug controls for gameplay
## Temporary script for testing the game loop

@onready var placement_system = $PlacementSystem
@onready var board = $Board
@onready var enemy_container = $EnemyContainer
@onready var tower_container = $TowerContainer
@onready var debug_label = $CanvasLayer/DebugLabel

# Preload enemy scene
var enemy_scene = preload("res://scenes/enemies/test_enemy.tscn")
const KING_SCENE := preload("res://scenes/towers/king.tscn")
const KING_FOOTPRINT_TILES := 2
var king_instance: Node2D = null


func _ready():
	# Connect to currency changes to update UI
	EventBus.gold_changed.connect(_on_gold_changed)
	_update_debug_label()
	_spawn_king_base()


func _input(event: InputEvent):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_P:
			# Start placing a pawn tower
			placement_system.start_placement("pawn", 50)

		elif event.keycode == KEY_K:
			# Spawn a test enemy
			_spawn_test_enemy()


func _spawn_test_enemy():
	if not enemy_scene:
		print("ERROR: test_enemy.tscn not found!")
		return

	var enemy = enemy_scene.instantiate()
	enemy_container.add_child(enemy)

	# Set a simple path from top to bottom
	var path: Array[Vector2] = [
		Vector2(512, 100),
		Vector2(512, 300),
		Vector2(512, 500),
		Vector2(512, 700)
	]
	enemy.set_path(path)

	print("Spawned test enemy")


func _on_gold_changed(new_amount: int):
	_update_debug_label()


func _update_debug_label():
	if debug_label:
		debug_label.text = "Gold: %d\nPress P to place Pawn tower (cost: 50)\nPress K to spawn test enemy\nRight-click to cancel placement" % CurrencyManager.get_current_gold()


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

	var start_index = board.chess_board_size + int(floor((board.cross_width - KING_FOOTPRINT_TILES) / 2.0))
	var center_index = start_index + KING_FOOTPRINT_TILES / 2.0
	var center = Vector2(center_index, center_index) * board.tile_size
	return center
