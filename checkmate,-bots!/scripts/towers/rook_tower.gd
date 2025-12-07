extends "res://scripts/core/tower.gd"

class_name RookTower

## Rook Tower - Horizontal/vertical line attack
## Attacks: All horizontal and vertical lines
## High cost, strong lane control


func _ready():
	tower_name = "Rook"
	tower_class = "rook"
	description = "Fires projectiles in all L/R/U/D directions. Strong lane control."

	base_cost = 10
	upgrade_cost = 10

	attack_damage = 5.0
	attack_cooldown = 1.5
	projectile_speed = 400.0
	uses_projectile = true
	projectile_scene = preload("res://scenes/projectiles/rook_projectile.tscn")

	super._ready()
	print("Rook tower ready at grid position: ", grid_position)


## Rook attack pattern: All horizontal and vertical lines (up to board edge)
func get_attack_pattern() -> Array[Vector2i]:
	var pattern: Array[Vector2i] = []

	# Horizontal and vertical lines in all 4 directions (up to 8 tiles away)
	for i in range(1, 9):
		pattern.append(Vector2i(i, 0))  # Right
		pattern.append(Vector2i(-i, 0))  # Left
		pattern.append(Vector2i(0, i))  # Down
		pattern.append(Vector2i(0, -i))  # Up

	return pattern


func _setup_visual():
	super._setup_visual()
	queue_redraw()


func _draw():
	# Placeholder: Draw a green circle for rook
	draw_circle(Vector2.ZERO, 20, Color.GREEN)
	draw_circle(Vector2.ZERO, 20, Color.BLACK, false, 2.0)
