extends Node2D
class_name PathManager

## Manages enemy paths on the map
## Supports multiple directional paths (north, east, south, west) converging to center base


@export_group("Path Configuration")
## Center position where the base is located (target for all paths)
@export var base_position: Vector2 = Vector2(400, 300)
## Show path visualization in editor and game
@export var show_path: bool = false
## Path colors for each direction
@export var north_color: Color = Color.CYAN
@export var east_color: Color = Color.YELLOW
@export var south_color: Color = Color.MAGENTA
@export var west_color: Color = Color.ORANGE
## Width of the path line
@export var path_width: float = 3.0
## Map boundaries for spawn points
@export var map_width: float = 800
@export var map_height: float = 600

# Dictionary to store paths for each direction
var paths: Dictionary = {
	"north": [],
	"east": [],
	"south": [],
	"west": []
}

signal path_updated(direction: String, new_path: Array[Vector2])


func _ready():
	_initialize_paths()

func _initialize_paths():
	_create_directional_paths()
	
	for direction in paths.keys():
		path_updated.emit(direction, paths[direction])

func _create_directional_paths():
	paths["north"] = [
		Vector2(base_position.x, 0),
		base_position
	]
	
	paths["east"] = [
		Vector2(map_width, base_position.y),
		base_position
	]
	
	paths["south"] = [
		Vector2(base_position.x, map_height),
		base_position
	]
	
	paths["west"] = [
		Vector2(0, base_position.y),
		base_position
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
