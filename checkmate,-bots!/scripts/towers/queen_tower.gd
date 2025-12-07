extends "res://scripts/core/tower.gd"

class_name QueenTower

## Queen Tower - All-direction attack
## Attacks: All directions (straight + diagonal lines)
## Highest cost, strongest coverage and firepower


func _ready():
	tower_name = "Queen"
	tower_class = "queen"
	description = "Fires projectiles in all L/R/U/D and diagonal directions. Supreme coverage and power."

	base_cost = 25
	upgrade_cost = 25

	attack_damage = 9.0
	attack_cooldown = 1.5
	projectile_speed = 400.0
	uses_projectile = true
	projectile_scene = preload("res://scenes/projectiles/queen_projectile.tscn")

	super._ready()
	print("Queen tower ready at grid position: ", grid_position)


## Queen attack pattern: Combines Rook + Bishop (all 8 directions)
func get_attack_pattern() -> Array[Vector2i]:
	var pattern: Array[Vector2i] = []

	# All 8 directions (horizontal, vertical, and diagonal lines)
	for i in range(1, 9):
		# Horizontal and vertical (Rook)
		pattern.append(Vector2i(i, 0))  # Right
		pattern.append(Vector2i(-i, 0))  # Left
		pattern.append(Vector2i(0, i))  # Down
		pattern.append(Vector2i(0, -i))  # Up

		# Diagonal (Bishop)
		pattern.append(Vector2i(i, i))  # Bottom-right
		pattern.append(Vector2i(i, -i))  # Top-right
		pattern.append(Vector2i(-i, i))  # Bottom-left
		pattern.append(Vector2i(-i, -i))  # Top-left

	return pattern


func _setup_visual():
	super._setup_visual()
	queue_redraw()


func _draw():
	# Placeholder: Draw a gold/yellow circle for queen
	draw_circle(Vector2.ZERO, 20, Color.GOLD)
	draw_circle(Vector2.ZERO, 20, Color.BLACK, false, 2.0)
