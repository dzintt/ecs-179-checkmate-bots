extends "res://scripts/core/tower.gd"
class_name PawnTower

## Pawn Tower - Basic chess piece tower
## Attacks: 1 tile forward and 2 diagonal forward tiles
## Low cost, short range, good for early defense

func _ready():
	super._ready()
	tower_class = "pawn"
	print("Pawn tower ready")


## Pawn attack pattern: 1 tile forward + 2 diagonal forward
func get_attack_pattern() -> Array[Vector2i]:
	var pattern: Array[Vector2i] = []

	# 1 tile forward (towards enemy spawn - assuming enemies come from top, so negative Y)
	pattern.append(Vector2i(0, -1))

	# 2 diagonal forward tiles
	pattern.append(Vector2i(-1, -1))
	pattern.append(Vector2i(1, -1))

	return pattern


## Override visual setup for pawn-specific appearance
func _setup_visual():
	super._setup_visual()
	queue_redraw()


func _draw():
	# Placeholder: Draw a white circle for pawn
	draw_circle(Vector2.ZERO, 20, Color.WHITE)
	draw_circle(Vector2.ZERO, 20, Color.BLACK, false, 2.0)
