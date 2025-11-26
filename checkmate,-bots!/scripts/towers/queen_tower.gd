extends "res://scripts/core/tower.gd"
class_name QueenTower

## Queen Tower - All-direction attack
## Attacks: All directions (straight + diagonal lines)
## Highest cost, strongest coverage and firepower

func _ready():
	super._ready()
	tower_class = "queen"
	use_grid_pattern = true

	print("Queen tower ready")


func _setup_visual():
	super._setup_visual()
	queue_redraw()


func _draw():
	# Placeholder: Draw a gold/yellow circle for queen
	draw_circle(Vector2.ZERO, 20, Color.GOLD)
	draw_circle(Vector2.ZERO, 20, Color.BLACK, false, 2.0)

	if attack_range > 0:
		draw_circle(Vector2.ZERO, attack_range, Color(1, 0.85, 0, 0.1))
		draw_circle(Vector2.ZERO, attack_range, Color.GOLD, false, 1.0)
