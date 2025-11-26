extends "res://scripts/core/tower.gd"
class_name BishopTower

## Bishop Tower - Diagonal line attack
## Attacks: All diagonal lines
## Medium-high cost, strong map coverage if positioned well

func _ready():
	super._ready()
	tower_class = "bishop"
	print("Bishop tower ready")


## Bishop attack pattern: All diagonal lines (up to board edge)
func get_attack_pattern() -> Array[Vector2i]:
	var pattern: Array[Vector2i] = []

	# Diagonal lines in all 4 directions (up to 8 tiles away for an 8x8 board)
	for i in range(1, 9):
		pattern.append(Vector2i(i, i))      # Bottom-right
		pattern.append(Vector2i(i, -i))     # Top-right
		pattern.append(Vector2i(-i, i))     # Bottom-left
		pattern.append(Vector2i(-i, -i))    # Top-left

	return pattern


func _setup_visual():
	super._setup_visual()
	queue_redraw()


func _draw():
	# Placeholder: Draw a purple circle for bishop
	draw_circle(Vector2.ZERO, 20, Color.PURPLE)
	draw_circle(Vector2.ZERO, 20, Color.BLACK, false, 2.0)
