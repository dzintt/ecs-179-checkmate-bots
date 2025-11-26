extends "res://scripts/core/tower.gd"
class_name KnightTower

## Knight Tower - L-shaped attack pattern
## Attacks: L-shape (2+1 in any direction)
## Medium cost, unique coverage, ignores obstacles

func _ready():
	super._ready()
	tower_class = "knight"
	use_grid_pattern = true

	print("Knight tower ready")


func _setup_visual():
	super._setup_visual()
	queue_redraw()


func _draw():
	# Placeholder: Draw a blue circle for knight
	draw_circle(Vector2.ZERO, 20, Color.SKY_BLUE)
	draw_circle(Vector2.ZERO, 20, Color.BLACK, false, 2.0)

	if attack_range > 0:
		draw_circle(Vector2.ZERO, attack_range, Color(0.5, 0.7, 1, 0.1))
		draw_circle(Vector2.ZERO, attack_range, Color.SKY_BLUE, false, 1.0)
