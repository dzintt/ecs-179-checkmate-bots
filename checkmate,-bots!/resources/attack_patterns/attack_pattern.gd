extends Resource
class_name AttackPattern

## Attack Pattern Resource - Defines chess piece attack shapes
## Used by towers to determine which grid tiles they can attack

enum PatternType { CIRCULAR, GRID_PATTERN, LINE_HORIZONTAL, LINE_VERTICAL, LINE_DIAGONAL, L_SHAPE }  # Circular radius (for King, or fallback)  # Custom grid pattern (chess pieces)  # Horizontal lines (Rook)  # Vertical lines (Rook)  # Diagonal lines (Bishop)  # L-shaped pattern (Knight)

@export var pattern_type: PatternType = PatternType.CIRCULAR
@export var pattern_tiles: Array[Vector2i] = []  # Relative grid positions from tower
@export var pattern_range: int = 3  # Max distance for line patterns

## Example patterns:
## Pawn: pattern_tiles = [Vector2i(0, -1), Vector2i(-1, -1), Vector2i(1, -1)]
## Knight: pattern_tiles = [Vector2i(2, 1), Vector2i(2, -1), Vector2i(-2, 1), Vector2i(-2, -1),
##                          Vector2i(1, 2), Vector2i(1, -2), Vector2i(-1, 2), Vector2i(-1, -2)]
