extends "res://scripts/core/tower.gd"

class_name KnightTower

## Knight Tower - L-shaped attack pattern
## Attacks: L-shape (2+1 in any direction)
## Medium cost, unique coverage, ignores obstacles


func _ready():
	tower_name = "Knight"
	tower_class = "knight"
	description = "Attacks with earthquake animation, summons only in ONE direction. Unique L-shaped coverage."

	base_cost = 3
	upgrade_cost = 5

	attack_damage = 3.0
	attack_cooldown = 1.25
	projectile_speed = 0.0

	super._ready()
	print("Knight tower ready at grid position: ", grid_position)


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
