extends Node
## Placement System - Handles tower placement interaction
## Manages preview, validation, and tower instantiation

var selected_tower_type: String = ""
var selected_tower_cost: int = 0
var is_placing: bool = false

@onready var placement_preview: Sprite2D = $PlacementPreview
@onready var tower_container: Node2D

signal placement_completed(tower: Node, position: Vector2)
signal placement_cancelled


func _ready():
	# Get tower container from parent World scene
	tower_container = get_node_or_null("../TowerContainer")

	if placement_preview:
		placement_preview.hide()


## Start tower placement mode
func start_placement(tower_type: String, cost: int):
	# Check if player can afford
	if not CurrencyManager.can_afford(cost):
		print("Cannot afford tower: ", tower_type, " (cost: ", cost, ")")
		if SoundManager:
			SoundManager.play_illegal_move()
		return

	selected_tower_type = tower_type
	selected_tower_cost = cost
	is_placing = true

	if placement_preview:
		placement_preview.show()

	print("Placement started: ", tower_type, " (cost: ", cost, ")")


## Cancel placement mode
func _cancel_placement():
	is_placing = false
	selected_tower_type = ""
	selected_tower_cost = 0

	if placement_preview:
		placement_preview.hide()

	placement_cancelled.emit()
	print("Placement cancelled")


## Handle input for placement
func _input(event: InputEvent):
	if not is_placing:
		return

	if event is InputEventMouseMotion:
		_update_preview_position(event.position)

	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_try_place_tower()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			_cancel_placement()


## Update placement preview position
func _update_preview_position(screen_pos: Vector2):
	if not placement_preview:
		return

	var world_pos = get_viewport().get_camera_2d().get_global_mouse_position()
	var grid_pos = GridSystem.world_to_grid(world_pos)
	var snapped_world_pos = GridSystem.grid_to_world(grid_pos)

	placement_preview.global_position = snapped_world_pos


## Try to place tower at current position
func _try_place_tower():
	var world_pos = get_viewport().get_camera_2d().get_global_mouse_position()
	var grid_pos = GridSystem.world_to_grid(world_pos)

	# Validate funds and placement
	if not CurrencyManager.can_afford(selected_tower_cost):
		if SoundManager:
			SoundManager.play_illegal_move()
		return

	if not GridSystem.is_valid_placement_tile(grid_pos):
		if SoundManager:
			SoundManager.play_illegal_move()
		return

	# Check currency
	if not CurrencyManager.spend_gold(selected_tower_cost):
		print("Cannot afford tower")
		if SoundManager:
			SoundManager.play_illegal_move()
		return

	# Instantiate tower
	var tower_scene = _get_tower_scene(selected_tower_type)
	if not tower_scene:
		print("ERROR: Could not load tower scene for ", selected_tower_type)
		return

	var tower = tower_scene.instantiate()
	var snapped_world_pos = GridSystem.grid_to_world(grid_pos)
	tower.global_position = snapped_world_pos

	# Mark tile as occupied to prevent stacking
	GridSystem.occupy_tile(grid_pos)

	if tower_container:
		tower_container.add_child(tower)
		print("Placed ", selected_tower_type, " tower at ", grid_pos)
		EventBus.tower_placed.emit(tower, snapped_world_pos, selected_tower_cost)
		placement_completed.emit(tower, snapped_world_pos)
	else:
		print("ERROR: TowerContainer not found!")
		tower.queue_free()

	_cancel_placement()


## Get the tower scene based on type
func _get_tower_scene(tower_type: String) -> PackedScene:
	var scene_path = "res://scenes/towers/" + tower_type + ".tscn"
	if ResourceLoader.exists(scene_path):
		return load(scene_path)
	return null
