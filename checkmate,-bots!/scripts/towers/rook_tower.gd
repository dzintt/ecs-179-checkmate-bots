extends "res://scripts/core/tower.gd"
class_name RookTower

## Rook Tower - Horizontal/vertical line attack
## Attacks: All horizontal and vertical lines
## High cost, strong lane control

func _ready():
	super._ready()
	tower_class = "rook"
	print("Rook tower ready")


## Rook attack pattern: All horizontal and vertical lines (up to board edge)
func get_attack_pattern() -> Array[Vector2i]:
	var pattern: Array[Vector2i] = []

	# Horizontal and vertical lines in all 4 directions (up to 8 tiles away)
	for i in range(1, 9):
		pattern.append(Vector2i(i, 0))      # Right
		pattern.append(Vector2i(-i, 0))     # Left
		pattern.append(Vector2i(0, i))      # Down
		pattern.append(Vector2i(0, -i))     # Up

	return pattern


func _setup_visual():
	super._setup_visual()
	queue_redraw()


func _draw():
	# Placeholder: Draw a green circle for rook
	draw_circle(Vector2.ZERO, 20, Color.GREEN)
	draw_circle(Vector2.ZERO, 20, Color.BLACK, false, 2.0)
