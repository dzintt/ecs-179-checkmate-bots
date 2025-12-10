extends Node2D

const GridSystem = preload("res://scripts/systems/grid_system.gd")

@export var chess_board_size: int = GridSystem.CHESS_BOARD_SIZE
@export var tile_size: float = float(GridSystem.TILE_SIZE)
@export var cross_width: int = GridSystem.CROSS_WIDTH
@export var frame_thickness: float = 48.0
@export var background_margin: float = 48.0

@export var chess_tile_color_light: Color = Color(0.35, 0.66, 0.80)
@export var chess_tile_color_dark: Color = Color(0.12, 0.22, 0.30)
@export var cross_color_light: Color = Color(0.30, 0.32, 0.48)
@export var cross_color_dark: Color = Color(0.16, 0.18, 0.30)
@export var frame_color: Color = Color(0.05, 0.12, 0.16, 0.35)
@export var background_color: Color = Color(0, 0, 0, 0)

var _tiles_root: Node2D


func _ready():
	chess_board_size = GridSystem.CHESS_BOARD_SIZE
	tile_size = float(GridSystem.TILE_SIZE)
	cross_width = GridSystem.CROSS_WIDTH

	_create_background()
	_create_frame()
	_create_board()
	_setup_camera()


func _create_background():
	var visual_extent = _visual_extent_px()
	var origin = Vector2(-frame_thickness - background_margin, -frame_thickness - background_margin)
	var background = _make_rect_polygon(
		origin, Vector2(visual_extent, visual_extent), background_color, "Background"
	)
	background.z_index = -15
	add_child(background)


func _create_frame():
	var board_px = _board_size_px()
	var t = frame_thickness
	var size = Vector2(board_px, board_px)
	var strips = [
		{"pos": Vector2(-t, -t), "size": Vector2(size.x + 2.0 * t, t)},  # Top
		{"pos": Vector2(-t, size.y), "size": Vector2(size.x + 2.0 * t, t)},  # Bottom
		{"pos": Vector2(-t, 0), "size": Vector2(t, size.y)},  # Left
		{"pos": Vector2(size.x, 0), "size": Vector2(t, size.y)},  # Right
	]

	for strip_data in strips:
		var strip = _make_rect_polygon(
			strip_data["pos"], strip_data["size"], frame_color, "FrameStrip"
		)
		strip.z_index = -10
		add_child(strip)

	_tiles_root = Node2D.new()
	_tiles_root.name = "Tiles"
	add_child(_tiles_root)


func _create_board():
	_create_chess_board(Vector2(0, 0), "top_left")
	_create_chess_board(Vector2((chess_board_size + cross_width) * tile_size, 0), "top_right")
	_create_chess_board(Vector2(0, (chess_board_size + cross_width) * tile_size), "bottom_left")
	_create_chess_board(
		Vector2(
			(chess_board_size + cross_width) * tile_size,
			(chess_board_size + cross_width) * tile_size
		),
		"bottom_right"
	)

	_create_cross_area()


func _create_chess_board(start_pos: Vector2, board_name: String):
	var board_node = Node2D.new()
	board_node.name = board_name
	_tiles_root.add_child(board_node)
	board_node.position = start_pos

	for x in range(chess_board_size):
		for y in range(chess_board_size):
			var tile = _create_tile(Vector2(x * tile_size, y * tile_size), (x + y) % 2 == 0, false)
			tile.name = "Tile_" + str(x) + "_" + str(y)
			board_node.add_child(tile)


func _create_cross_area():
	var cross_node = Node2D.new()
	cross_node.name = "cross_spawn_area"
	_tiles_root.add_child(cross_node)

	# Horizontal bar of the cross
	for x in range(chess_board_size * 2 + cross_width):
		for y in range(cross_width):
			var tile = _create_tile(
				Vector2(x * tile_size, (chess_board_size + y) * tile_size), (x + y) % 2 == 0, true
			)
			tile.name = "SpawnTile_H_" + str(x) + "_" + str(y)
			cross_node.add_child(tile)

	# Vertical bar of the cross excluding intersection
	for x in range(cross_width):
		for y in range(chess_board_size * 2 + cross_width):
			if y >= chess_board_size and y < chess_board_size + cross_width:
				continue  # Skip intersection (already created above)

			var tile = _create_tile(
				Vector2((chess_board_size + x) * tile_size, y * tile_size), (x + y) % 2 == 0, true
			)
			tile.name = "SpawnTile_V_" + str(x) + "_" + str(y)
			cross_node.add_child(tile)


func _create_tile(pos: Vector2, is_light: bool, is_spawn: bool) -> ColorRect:
	var tile = ColorRect.new()
	tile.position = pos
	tile.size = Vector2(tile_size, tile_size)
	tile.color = _get_tile_color(is_light, is_spawn)
	tile.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tile.z_index = 0
	return tile


func _get_tile_color(is_light: bool, is_spawn: bool) -> Color:
	if is_spawn:
		return cross_color_light if is_light else cross_color_dark
	return chess_tile_color_light if is_light else chess_tile_color_dark


func _make_rect_polygon(origin: Vector2, size: Vector2, color: Color, name: String) -> Polygon2D:
	var poly = Polygon2D.new()
	poly.name = name
	poly.position = origin
	poly.polygon = _rect_to_polygon(Vector2.ZERO, size)
	poly.uv = poly.polygon
	poly.color = color
	return poly


func _rect_to_polygon(origin: Vector2, size: Vector2) -> PackedVector2Array:
	return PackedVector2Array(
		[
			origin,
			origin + Vector2(size.x, 0),
			origin + size,
			origin + Vector2(0, size.y),
		]
	)


func _board_size_px() -> float:
	return (chess_board_size * 2 + cross_width) * tile_size


func _visual_extent_px() -> float:
	return _board_size_px() + 2.0 * (frame_thickness + background_margin)


func _setup_camera():
	var camera = Camera2D.new()
	camera.name = "BoardCamera"
	add_child(camera)

	# Position camera at the center of the board tiles
	var board_px = _board_size_px()
	camera.position = Vector2(board_px / 2.0, board_px / 2.0)

	# Zoom to include frame/backdrop with a small margin
	var visual_size = _visual_extent_px()
	var viewport_size = get_viewport().get_visible_rect().size
	var zoom_x = viewport_size.x / (visual_size * 1.05)
	var zoom_y = viewport_size.y / (visual_size * 1.05)
	var zoom_level = min(zoom_x, zoom_y)

	camera.zoom = Vector2(zoom_level, zoom_level)
	camera.enabled = true
