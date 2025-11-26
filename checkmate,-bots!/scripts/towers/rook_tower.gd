extends "res://scripts/core/tower.gd"
class_name RookTower

## Rook Tower - Horizontal/vertical line attack
## Attacks: All horizontal and vertical lines
## High cost, strong lane control

func _ready():
	super._ready()
	tower_class = "rook"
	use_grid_pattern = true

	print("Rook tower ready")


func _setup_visual():
	super._setup_visual()
	queue_redraw()


func _draw():
	# Placeholder: Draw a green circle for rook
	draw_circle(Vector2.ZERO, 20, Color.GREEN)
	draw_circle(Vector2.ZERO, 20, Color.BLACK, false, 2.0)

	if attack_range > 0:
		draw_circle(Vector2.ZERO, attack_range, Color(0.2, 0.8, 0.2, 0.1))
		draw_circle(Vector2.ZERO, attack_range, Color.GREEN, false, 1.0)
