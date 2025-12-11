extends Node
## Placement System - Handles tower placement interaction
## Manages preview, validation, and tower instantiation

var selected_tower_type: String = ""
var selected_tower_cost: int = 0
var is_placing: bool = false

@onready var placement_preview: Sprite2D = $PlacementPreview
@onready var tower_container: Node2D
var range_overlay: Node2D
var _overlay_pool: Array[ColorRect] = []
const RANGE_COLOR := Color(0.1, 0.9, 0.2, 0.28)
var ghost_tower: Node2D = null

signal placement_completed(tower: Node, position: Vector2)
signal placement_cancelled


func _ready():
	# Get tower container from parent World scene
	tower_container = get_node_or_null("../TowerContainer")

	range_overlay = Node2D.new()
	range_overlay.name = "RangeOverlay"
	add_child(range_overlay)

	if placement_preview:
		placement_preview.hide()


func _process(_delta):
	# Safety: if we exit placement unexpectedly, make sure visuals are hidden.
	if not is_placing:
		_clear_range_preview()
		_clear_ghost_tower()


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

	# Reset any previous visuals before showing new ones.
	_clear_range_preview()
	_clear_ghost_tower()

	if placement_preview:
		placement_preview.show()

	_spawn_ghost_tower()
	_refresh_range_preview_from_mouse()

	print("Placement started: ", tower_type, " (cost: ", cost, ")")


## Cancel placement mode
func cancel_placement():
	is_placing = false
	selected_tower_type = ""
	selected_tower_cost = 0

	if placement_preview:
		placement_preview.hide()

	_clear_range_preview()
	_clear_ghost_tower()

	placement_cancelled.emit()
	print("Placement cancelled")


## Handle input for placement
func _input(event: InputEvent):
	if not is_placing:
		return

	if event is InputEventMouseMotion:
		_update_preview_position()

	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_try_place_tower()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			cancel_placement()


## Update placement preview position
func _update_preview_position():
	if not placement_preview:
		return

	var world_pos = get_viewport().get_camera_2d().get_global_mouse_position()
	var grid_pos = GridSystem.world_to_grid(world_pos)
	var snapped_world_pos = GridSystem.grid_to_world(grid_pos)

	placement_preview.global_position = snapped_world_pos
	_update_ghost_position(grid_pos)
	_update_range_preview(grid_pos)


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

	cancel_placement()


## Get the tower scene based on type
func _get_tower_scene(tower_type: String) -> PackedScene:
	var scene_path = "res://scenes/towers/" + tower_type + ".tscn"
	if ResourceLoader.exists(scene_path):
		return load(scene_path)
	return null


func _refresh_range_preview_from_mouse():
	var cam := get_viewport().get_camera_2d()
	if cam == null:
		return
	var world_pos = cam.get_global_mouse_position()
	var grid_pos = GridSystem.world_to_grid(world_pos)
	_update_range_preview(grid_pos)


func _get_attack_pattern_for_selected() -> Array[Vector2i]:
	if selected_tower_type.is_empty():
		return []
	var scene = _get_tower_scene(selected_tower_type)
	if scene == null:
		return []
	var temp_tower = scene.instantiate()
	var pattern: Array[Vector2i] = []
	if temp_tower and temp_tower.has_method("get_attack_pattern"):
		pattern = temp_tower.get_attack_pattern()
	if temp_tower is Node:
		temp_tower.queue_free()
	return pattern


func _spawn_ghost_tower():
	_clear_ghost_tower()
	if selected_tower_type.is_empty():
		return
	var scene = _get_tower_scene(selected_tower_type)
	if scene == null:
		return
	var temp = scene.instantiate()
	if temp == null:
		return
	ghost_tower = temp
	if ghost_tower is Node:
		ghost_tower.process_mode = Node.PROCESS_MODE_DISABLED
	if ghost_tower is CanvasItem:
		ghost_tower.modulate = Color(1, 1, 1, 0.4)
	add_child(ghost_tower)


func _update_ghost_position(grid_pos: Vector2i):
	if ghost_tower == null:
		return
	ghost_tower.global_position = GridSystem.grid_to_world(grid_pos)


func _clear_ghost_tower():
	if ghost_tower != null and is_instance_valid(ghost_tower):
		ghost_tower.queue_free()
	ghost_tower = null


func _update_range_preview(origin_grid: Vector2i):
	var pattern = _get_attack_pattern_for_selected()
	if pattern.is_empty():
		_clear_range_preview()
		return

	_ensure_overlay_pool(pattern.size())
	var tile_size = Vector2(GridSystem.TILE_SIZE, GridSystem.TILE_SIZE)
	var used := 0

	for offset in pattern:
		var target = origin_grid + offset
		if not GridSystem.is_within_board(target):
			continue

		if used >= _overlay_pool.size():
			break

		var rect := _overlay_pool[used]
		used += 1
		rect.visible = true
		rect.size = tile_size
		rect.position = GridSystem.grid_to_world(target) - tile_size / 2.0
		rect.color = RANGE_COLOR

	for i in range(used, _overlay_pool.size()):
		_overlay_pool[i].visible = false


func _clear_range_preview():
	for rect in _overlay_pool:
		rect.visible = false


func _ensure_overlay_pool(count: int):
	while _overlay_pool.size() < count:
		var rect = ColorRect.new()
		rect.visible = false
		rect.size = Vector2(GridSystem.TILE_SIZE, GridSystem.TILE_SIZE)
		rect.color = RANGE_COLOR
		range_overlay.add_child(rect)
		_overlay_pool.append(rect)
