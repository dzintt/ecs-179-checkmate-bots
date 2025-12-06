extends "res://scripts/core/tower.gd"

class_name PawnTower

## Pawn Tower - Basic chess piece tower
## Attacks: 1 tile forward and 2 diagonal forward tiles
## Low cost, short range, good for early defense


func _ready():
	tower_name = "Pawn"
	tower_class = "pawn"
	description = "Attacks with a wave animation like swinging a sword. Basic defensive tower."

	base_cost = 1
	upgrade_cost = 1

	attack_damage = 1.0
	attack_cooldown = 1.0
	projectile_speed = 0.0

	super._ready()
	print("Pawn tower ready at grid position: ", grid_position)


## Pawn attack pattern: 1 tile forward + 2 diagonal forward
func get_attack_pattern() -> Array[Vector2i]:
	var pattern: Array[Vector2i] = []

	pattern.append(Vector2i(0, -1))
	pattern.append(Vector2i(0, -2))
	pattern.append(Vector2i(0, 1))
	pattern.append(Vector2i(0, 2))
	pattern.append(Vector2i(-1, 0))
	pattern.append(Vector2i(-2, 0))
	pattern.append(Vector2i(1, 0))
	pattern.append(Vector2i(2, 0))

	return pattern


## Override visual setup for pawn-specific appearance
func _setup_visual():
	super._setup_visual()
	queue_redraw()


func _draw():
	# Placeholder: Draw a white circle for pawn
	draw_circle(Vector2.ZERO, 20, Color.WHITE)
	draw_circle(Vector2.ZERO, 20, Color.BLACK, false, 2.0)
