extends Node2D

## World Controller - Test/debug controls for gameplay
## Temporary script for testing the game loop

@onready var placement_system = $PlacementSystem
@onready var enemy_container = $EnemyContainer
@onready var debug_label = $CanvasLayer/DebugLabel

# Preload enemy scene
var enemy_scene = preload("res://scenes/enemies/test_enemy.tscn")


func _ready():
	# Connect to currency changes to update UI
	EventBus.gold_changed.connect(_on_gold_changed)
	_update_debug_label()


func _input(event: InputEvent):
	if event.is_action_pressed("ui_accept"):  # P key
		# Start placing a pawn tower
		placement_system.start_placement("pawn", 50)

	elif event is InputEventKey and event.pressed and event.keycode == KEY_K:
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
