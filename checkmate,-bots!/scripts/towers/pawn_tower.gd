extends "res://scripts/core/tower.gd"
class_name PawnTower

## Pawn Tower - Basic chess piece tower
## Attacks: 1 tile forward and 2 diagonal forward tiles
## Low cost, short range, good for early defense

func _ready():
	super._ready()
	tower_class = "pawn"
	use_grid_pattern = true  # Will use chess pattern when implemented

	print("Pawn tower ready")


## Override visual setup for pawn-specific appearance
func _setup_visual():
	super._setup_visual()
	# TODO: Add pawn sprite/visual
	queue_redraw()


func _draw():
	# Placeholder: Draw a white circle for pawn
	draw_circle(Vector2.ZERO, 20, Color.WHITE)
	draw_circle(Vector2.ZERO, 20, Color.BLACK, false, 2.0)

	# Draw attack range (if enabled)
	if attack_range > 0:
		draw_circle(Vector2.ZERO, attack_range, Color(1, 1, 1, 0.1))
		draw_circle(Vector2.ZERO, attack_range, Color.WHITE, false, 1.0)
