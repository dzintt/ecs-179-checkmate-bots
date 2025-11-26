extends Node

class_name GridSystem

## Grid System - Utility functions for grid/world coordinate conversion
## Static class - no need to instantiate

const TILE_SIZE: int = 64


## Convert world position to grid coordinates
static func world_to_grid(world_pos: Vector2) -> Vector2i:
	return Vector2i(
		int(floor(world_pos.x / TILE_SIZE)),
		int(floor(world_pos.y / TILE_SIZE)),
	)


## Convert grid coordinates to world position (center of tile)
static func grid_to_world(grid_pos: Vector2i) -> Vector2:
	return Vector2(
		grid_pos.x * TILE_SIZE + TILE_SIZE / 2.0,
		grid_pos.y * TILE_SIZE + TILE_SIZE / 2.0,
	)


## Check if a grid position is valid for tower placement
static func is_valid_placement_tile(grid_pos: Vector2i, board: Node2D = null) -> bool:
	# TODO: Implement proper validation
	# - Check if tile is on chess board (not spawn area)
	# - Check if tile is not already occupied
	# - Query board's tile_metadata

	# Placeholder: Always return true for now
	return true


## Check if a tile is occupied by a tower
static func is_tile_occupied(grid_pos: Vector2i) -> bool:
	# TODO: Query tile occupancy from board
	# Placeholder
	return false
