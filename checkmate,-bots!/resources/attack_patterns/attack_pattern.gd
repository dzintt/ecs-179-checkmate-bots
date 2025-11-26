extends Resource
class_name AttackPattern

## Attack Pattern Resource - Defines chess piece attack shapes
## Used by towers to determine which grid tiles they can attack

enum PatternType {
	CIRCULAR,         # Circular radius (for King, or fallback)
	GRID_PATTERN,     # Custom grid pattern (chess pieces)
	LINE_HORIZONTAL,  # Horizontal lines (Rook)
	LINE_VERTICAL,    # Vertical lines (Rook)
	LINE_DIAGONAL,    # Diagonal lines (Bishop)
	L_SHAPE          # L-shaped pattern (Knight)
}

@export var pattern_type: PatternType = PatternType.CIRCULAR
@export var pattern_tiles: Array[Vector2i] = []  # Relative grid positions from tower
@export var pattern_range: int = 3  # Max distance for line patterns

## Example patterns:
## Pawn: pattern_tiles = [Vector2i(0, -1), Vector2i(-1, -1), Vector2i(1, -1)]
## Knight: pattern_tiles = [Vector2i(2, 1), Vector2i(2, -1), Vector2i(-2, 1), Vector2i(-2, -1),
##                          Vector2i(1, 2), Vector2i(1, -2), Vector2i(-1, 2), Vector2i(-1, -2)]
