extends "res://scripts/core/tower.gd"
class_name KnightTower

## Knight Tower - L-shaped attack pattern
## Attacks: L-shape (2+1 in any direction)
## Medium cost, unique coverage, ignores obstacles

func _ready():
	super._ready()
	tower_class = "knight"
	print("Knight tower ready")


## Knight attack pattern: All 8 L-shaped moves
func get_attack_pattern() -> Array[Vector2i]:
	var pattern: Array[Vector2i] = []

	# All 8 L-shaped knight moves
	pattern.append(Vector2i(2, 1))
	pattern.append(Vector2i(2, -1))
	pattern.append(Vector2i(-2, 1))
	pattern.append(Vector2i(-2, -1))
	pattern.append(Vector2i(1, 2))
	pattern.append(Vector2i(1, -2))
	pattern.append(Vector2i(-1, 2))
	pattern.append(Vector2i(-1, -2))

	return pattern


func _setup_visual():
	super._setup_visual()
	queue_redraw()


func _draw():
	# Placeholder: Draw a blue circle for knight
	draw_circle(Vector2.ZERO, 20, Color.SKY_BLUE)
	draw_circle(Vector2.ZERO, 20, Color.BLACK, false, 2.0)
