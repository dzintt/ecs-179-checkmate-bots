extends Node2D
class_name PathManager

const GridSystem = preload("res://scripts/systems/grid_system.gd")

## Manages enemy paths on the map
## Supports multiple directional paths (north, east, south, west) converging to center base

@export_group("Path Configuration")
## Center position where the base is located (target for all paths)
@export var base_position: Vector2 = Vector2(400, 300)
## Show path visualization in editor and game
@export var show_path: bool = true
## Path colors for each direction
@export var north_color: Color = Color.CYAN
@export var east_color: Color = Color.YELLOW
@export var south_color: Color = Color.MAGENTA
@export var west_color: Color = Color.ORANGE
## Width of the path line
@export var path_width: float = 3.0
## Automatically derive map size and base position from GridSystem (board center)
@export var auto_config_from_grid: bool = true
## Map boundaries for spawn points
@export var map_width: float = 800
@export var map_height: float = 600

# Dictionary to store paths for each direction
var paths: Dictionary = {
	"north": [],
	"north2": [],
	"east": [],
	"east2": [],
	"south": [],
	"south2": [],
	"west": [],
	"west2": []
}

signal path_updated(direction: String, new_path: Array[Vector2])

func _ready():
	if auto_config_from_grid:
		_sync_with_grid()
	await get_tree().process_frame
	_initialize_paths()

func _initialize_paths():
	_create_directional_paths()
	for direction in paths.keys():
		path_updated.emit(direction, paths[direction])

func _create_directional_paths():
	var king = get_tree().get_first_node_in_group("king")
	var actual_base_pos = base_position
	
	if king:
		actual_base_pos = king.global_position
		
	var tile_size = GridSystem.TILE_SIZE
	var chess_board = GridSystem.CHESS_BOARD_SIZE
	
	var north_left_x  = chess_board * tile_size + tile_size / 2.0
	var north_right_x = (chess_board + GridSystem.CROSS_WIDTH - 1) * tile_size + tile_size / 2.0
	
	var south_y = map_height
	var east_x  = map_width
	var west_x  = 0
	var north_y = 0
	
	var east_left_y  = chess_board * tile_size + tile_size / 2.0
	var east_right_y = (chess_board + GridSystem.CROSS_WIDTH - 1) * tile_size + tile_size / 2.0
	
	# NORTH lanes - come from top, move down to king
	paths["north"] = [
		Vector2(north_left_x, north_y),
		Vector2(north_left_x, actual_base_pos.y - tile_size),
		actual_base_pos,
	]
	
	paths["north2"] = [
		Vector2(north_right_x, north_y),
		Vector2(north_right_x, actual_base_pos.y - tile_size),
		actual_base_pos,
	]
	
	# SOUTH lanes - come from bottom, move up to king
	paths["south"] = [
		Vector2(north_left_x, south_y),
		Vector2(north_left_x, actual_base_pos.y + tile_size),
		actual_base_pos,
	]
	
	paths["south2"] = [
		Vector2(north_right_x, south_y),
		Vector2(north_right_x, actual_base_pos.y + tile_size),
		actual_base_pos,
	]
	
	# EAST lanes - come from right, move left to king
	paths["east"] = [
		Vector2(east_x, east_left_y),
		Vector2(actual_base_pos.x + tile_size, east_left_y),
		actual_base_pos,
	]
	
	paths["east2"] = [
		Vector2(east_x, east_right_y),
		Vector2(actual_base_pos.x + tile_size, east_right_y),
		actual_base_pos,
	]
	
	# WEST lanes - come from left, move right to king
	paths["west"] = [
		Vector2(west_x, east_left_y),
		Vector2(actual_base_pos.x - tile_size, east_left_y),
		actual_base_pos,
	]
	
	paths["west2"] = [
		Vector2(west_x, east_right_y),
		Vector2(actual_base_pos.x - tile_size, east_right_y),
		actual_base_pos,
	]

func get_direction_path(direction: String) -> Array[Vector2]:
	if not paths.has(direction):
		push_error("Invalid direction: " + direction)
		return []
	
	var global_path: Array[Vector2] = []
	for point in paths[direction]:
		global_path.append(global_position + point)
	
	return global_path

# Can be used to show spawn point like portal effect, and display where enemies will come
func get_start_position(direction: String) -> Vector2:
	if not paths.has(direction) or paths[direction].is_empty():
		return Vector2.ZERO
	return global_position + paths[direction][0]

func _sync_with_grid():
	var total_tiles := GridSystem.total_board_tiles()
	var total_size := float(total_tiles * GridSystem.TILE_SIZE)
	map_width = total_size
	map_height = total_size
	
	var cross_start = GridSystem.CHESS_BOARD_SIZE
	var cross_mid = cross_start + float(GridSystem.CROSS_WIDTH) / 2.0
	
	base_position = Vector2(
		cross_mid * GridSystem.TILE_SIZE,
		cross_mid * GridSystem.TILE_SIZE
	)
