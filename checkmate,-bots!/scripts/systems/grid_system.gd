extends Node

class_name GridSystem

const TILE_SIZE: int = 64
const CHESS_BOARD_SIZE: int = 8
const CROSS_WIDTH: int = 2

static var occupied_tiles: Dictionary = {}


static func world_to_grid(world_pos: Vector2) -> Vector2i:
	return Vector2i(
		int(floor(world_pos.x / TILE_SIZE)),
		int(floor(world_pos.y / TILE_SIZE)),
	)


static func grid_to_world(grid_pos: Vector2i) -> Vector2:
	return Vector2(
		grid_pos.x * TILE_SIZE + TILE_SIZE / 2.0,
		grid_pos.y * TILE_SIZE + TILE_SIZE / 2.0,
	)


static func is_cross_tile(grid_pos: Vector2i) -> bool:
	var cross_start = CHESS_BOARD_SIZE
	var cross_end = CHESS_BOARD_SIZE + CROSS_WIDTH - 1
	return (
		(grid_pos.x >= cross_start and grid_pos.x <= cross_end)
		or (grid_pos.y >= cross_start and grid_pos.y <= cross_end)
	)


static func is_tile_occupied(grid_pos: Vector2i) -> bool:
	return occupied_tiles.has(grid_pos)


static func is_within_board(grid_pos: Vector2i) -> bool:
	var total_size = CHESS_BOARD_SIZE * 2 + CROSS_WIDTH  # 8 + 2 + 8 = 18 by default
	return (
		grid_pos.x >= 0 and grid_pos.y >= 0 and grid_pos.x < total_size and grid_pos.y < total_size
	)


static func occupy_tile(grid_pos: Vector2i):
	occupied_tiles[grid_pos] = true


static func release_tile(grid_pos: Vector2i):
	occupied_tiles.erase(grid_pos)


static func reset():
	occupied_tiles.clear()


static func is_valid_placement_tile(grid_pos: Vector2i) -> bool:
	if not is_within_board(grid_pos):
		return false
	if is_cross_tile(grid_pos):
		return false
	if is_tile_occupied(grid_pos):
		return false
	return true
