extends Node2D

# Board configuration - easy to change
@export var chess_board_size: int = 8
@export var tile_size: float = 64.0
@export var cross_width: int = 2  # Width of the cross spawn area

# Colors for different areas
var chess_tile_color_light: Color = Color("White")
var chess_tile_color_dark: Color = Color("Black")
var cross_color: Color = Color("Dark Green")

func _ready():
	_create_board()
	_setup_camera()

func _create_board():
	# Create the four chess boards in corners
	_create_chess_board(Vector2(0, 0), "top_left")
	_create_chess_board(Vector2((chess_board_size + cross_width) * tile_size, 0), "top_right")
	_create_chess_board(Vector2(0, (chess_board_size + cross_width) * tile_size), "bottom_left")
	_create_chess_board(Vector2((chess_board_size + cross_width) * tile_size, (chess_board_size + cross_width) * tile_size), "bottom_right")
	
	# Create the cross-shaped spawn area
	_create_cross_area()

func _create_chess_board(start_pos: Vector2, board_name: String):
	var board_node = Node2D.new()
	board_node.name = board_name
	add_child(board_node)
	board_node.position = start_pos
	
	for x in range(chess_board_size):
		for y in range(chess_board_size):
			var tile = _create_tile(Vector2(x * tile_size, y * tile_size), (x + y) % 2 == 0,false)
			tile.name = "Tile_" + str(x) + "_" + str(y)
			board_node.add_child(tile)

func _create_cross_area():
	var cross_node = Node2D.new()
	cross_node.name = "cross_spawn_area"
	add_child(cross_node)
	
	# Horizontal bar of the cross
	for x in range(chess_board_size * 2 + cross_width):
		for y in range(cross_width):
			var tile = _create_tile(Vector2(x * tile_size, (chess_board_size + y) * tile_size), true, true)
			tile.name = "SpawnTile_H_" + str(x) + "_" + str(y)
			cross_node.add_child(tile)
	
	# Vertical bar of the cross excluding intersection
	for x in range(cross_width):
		for y in range(chess_board_size * 2 + cross_width):
			if y >= chess_board_size and y < chess_board_size + cross_width:
				continue  # Skip intersection (already created above)
			
			var tile = _create_tile(Vector2((chess_board_size + x) * tile_size, y * tile_size), true, true)
			tile.name = "SpawnTile" + str(x) + "_" + str(y)
			cross_node.add_child(tile)

func _create_tile(pos: Vector2, is_light_or_spawn: bool, is_spawn: bool) -> ColorRect:
	var tile = ColorRect.new()
	tile.size = Vector2(tile_size, tile_size)
	tile.position = pos
	
	if is_spawn:
		tile.color = cross_color
	else:
		tile.color = chess_tile_color_light if is_light_or_spawn else chess_tile_color_dark
	
	return tile

# Helper function to get tile position from grid coordinates
func get_tile_position(board_name: String, x: int, y: int) -> Vector2:
	var board = get_node_or_null(board_name)
	if board:
		return board.position + Vector2(x * tile_size + tile_size / 2, y * tile_size + tile_size / 2)
	return Vector2.ZERO

# I think we can put this in another file if we want
func _setup_camera():
	var camera = Camera2D.new()
	camera.name = "BoardCamera"
	add_child(camera)
	
	# Calculate the total board size
	var total_size = (chess_board_size * 2 + cross_width) * tile_size
	
	# Position camera at the center of the board
	camera.position = Vector2(total_size / 2, total_size / 2)
	
	var viewport_size = get_viewport().get_visible_rect().size
	var zoom_x = viewport_size.x / (total_size * 1.1) # can adjust if bigger map
	var zoom_y = viewport_size.y / (total_size * 1.1)
	var zoom_level = min(zoom_x, zoom_y)
	
	camera.zoom = Vector2(zoom_level, zoom_level)
	camera.enabled = true
