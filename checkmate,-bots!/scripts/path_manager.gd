extends Node2D
class_name PathManager

## Manages enemy paths on the map
## Define waypoints visually in the editor or programmatically


@export_group("Path Configuration")
## Manually defined waypoints (set in inspector)
@export var waypoints: Array[Vector2] = []
## Automatically calculate path from tilemap grid
@export var use_grid_path: bool = false
## Show path visualization in editor and game
@export var show_path: bool = true
## Path color for visualization
@export var path_color: Color = Color.YELLOW
## Width of the path line
@export var path_width: float = 3.0


var path_points: Array[Vector2] = []


signal path_updated(new_path: Array[Vector2])


func _ready():
	_initialize_path()
	if show_path:
		queue_redraw()

func _draw():
	if not show_path or path_points.size() < 2:
		return
	
	# Draw the path line
	for i in range(path_points.size() - 1):
		var start = path_points[i]
		var end = path_points[i + 1]
		draw_line(start, end, path_color, path_width)
	
	# Draw waypoint markers
	for i in range(path_points.size()):
		var point = path_points[i]
		draw_circle(point, 8, path_color)
		draw_circle(point, 8, Color.BLACK, false, 2.0)
		
		# Draw waypoint number
		var text = str(i)
		draw_string(ThemeDB.fallback_font, point + Vector2(-4, 4), text, HORIZONTAL_ALIGNMENT_CENTER, -1, 12)

## Initialize the path based on configuration
func _initialize_path():
	if use_grid_path:
		_generate_grid_path()
	elif not waypoints.is_empty():
		path_points = waypoints.duplicate()
	else:
		_create_default_path()
	
	path_updated.emit(path_points)

## Create a simple default path (example)
func _create_default_path():
	# Random path for now
	path_points = [
		Vector2(0, 0),
		Vector2(200, 0),
		Vector2(200, 200),
		Vector2(400, 200),
		Vector2(400, 0),
		Vector2(600, 0)
	]

## Generate a path based on a grid/tilemap
func _generate_grid_path():
	# TODO: Implement A* pathfinding or manual grid-based path
	# For now, use default path
	_create_default_path()

## Get the path that enemies should follow (in global coordinates)
func get_path() -> Array[Vector2]:
	var global_path: Array[Vector2] = []
	for point in path_points:
		global_path.append(global_position + point)
	return global_path

## Add a waypoint to the path
func add_waypoint(position: Vector2):
	path_points.append(position)
	path_updated.emit(path_points)
	queue_redraw()

## Remove a waypoint by index
func remove_waypoint(index: int):
	if index >= 0 and index < path_points.size():
		path_points.remove_at(index)
		path_updated.emit(path_points)
		queue_redraw()

## Clear all waypoints
func clear_path():
	path_points.clear()
	path_updated.emit(path_points)
	queue_redraw()

## Set the entire path at once
func set_path(new_path: Array[Vector2]):
	path_points = new_path.duplicate()
	path_updated.emit(path_points)
	queue_redraw()

## Insert a waypoint at a specific index
func insert_waypoint(index: int, position: Vector2):
	if index >= 0 and index <= path_points.size():
		path_points.insert(index, position)
		path_updated.emit(path_points)
		queue_redraw()

## Update an existing waypoint's position
func update_waypoint(index: int, position: Vector2):
	if index >= 0 and index < path_points.size():
		path_points[index] = position
		path_updated.emit(path_points)
		queue_redraw()

## Get the total length of the path
func get_path_length() -> float:
	var length: float = 0.0
	for i in range(path_points.size() - 1):
		length += path_points[i].distance_to(path_points[i + 1])
	return length

## Get a position along the path by percentage (0.0 to 1.0)
func get_position_at_percent(percent: float) -> Vector2:
	if path_points.size() < 2:
		return Vector2.ZERO
	
	percent = clamp(percent, 0.0, 1.0)
	var target_length = get_path_length() * percent
	var current_length: float = 0.0
	
	for i in range(path_points.size() - 1):
		var segment_start = path_points[i]
		var segment_end = path_points[i + 1]
		var segment_length = segment_start.distance_to(segment_end)
		
		if current_length + segment_length >= target_length:
			var segment_percent = (target_length - current_length) / segment_length
			return segment_start.lerp(segment_end, segment_percent)
		
		current_length += segment_length
	
	return path_points[-1]



## Get the number of waypoints
func get_waypoint_count() -> int:
	return path_points.size()

## Check if the path is valid (at least 2 points)
func is_path_valid() -> bool:
	return path_points.size() >= 2

## Get the start position of the path
func get_start_position() -> Vector2:
	if path_points.is_empty():
		return Vector2.ZERO
	return global_position + path_points[0]

## Get the end position of the path
func get_end_position() -> Vector2:
	if path_points.is_empty():
		return Vector2.ZERO
	return global_position + path_points[-1]

