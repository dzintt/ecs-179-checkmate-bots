extends "res://scripts/core/tower.gd"
class_name BishopTower

## Bishop Tower - Diagonal line attack
## Attacks: All diagonal lines
## Medium-high cost, strong map coverage if positioned well

func _ready():
	super._ready()
	tower_class = "bishop"
	use_grid_pattern = true

	print("Bishop tower ready")


func _setup_visual():
	super._setup_visual()
	queue_redraw()


func _draw():
	# Placeholder: Draw a purple circle for bishop
	draw_circle(Vector2.ZERO, 20, Color.PURPLE)
	draw_circle(Vector2.ZERO, 20, Color.BLACK, false, 2.0)

	if attack_range > 0:
		draw_circle(Vector2.ZERO, attack_range, Color(0.6, 0.2, 0.8, 0.1))
		draw_circle(Vector2.ZERO, attack_range, Color.PURPLE, false, 1.0)
