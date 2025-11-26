extends "res://scripts/core/tower.gd"
class_name KingBase

## King Base - Player's main base (must protect)
## Attacks: 1 tile in all 8 directions (circular range, small)
## Has health pool - if destroyed, player loses

@export var max_health: int = 100
var current_health: int

signal king_health_changed(current: int, max: int)
signal king_died()


func _ready():
	super._ready()
	tower_class = "king"
	use_grid_pattern = false  # King uses circular range
	current_health = max_health

	# Set smaller attack range for king
	attack_range = 80.0
	set_attack_range(attack_range)

	print("King initialized with ", current_health, " health")


## King takes damage from enemies reaching base
func take_damage(damage: int):
	current_health -= damage
	current_health = max(0, current_health)

	king_health_changed.emit(current_health, max_health)
	EventBus.king_damaged.emit(current_health, max_health)

	print("King damaged! Health: ", current_health, "/", max_health)

	if current_health <= 0:
		_die()


## King is destroyed - game over
func _die():
	king_died.emit()
	EventBus.king_destroyed.emit()
	GameManager.end_game(false)  # Player loses
	print("King destroyed! Game Over!")


func _setup_visual():
	super._setup_visual()
	queue_redraw()


func _draw():
	# Placeholder: Draw a large red circle with crown symbol
	draw_circle(Vector2.ZERO, 32, Color.DARK_RED)
	draw_circle(Vector2.ZERO, 32, Color.BLACK, false, 3.0)

	# Draw health percentage as inner circle
	var health_percent = float(current_health) / float(max_health)
	draw_circle(Vector2.ZERO, 25, Color(1, health_percent, health_percent, 0.7))

	# Draw attack range
	if attack_range > 0:
		draw_circle(Vector2.ZERO, attack_range, Color(1, 0.2, 0.2, 0.1))
		draw_circle(Vector2.ZERO, attack_range, Color.DARK_RED, false, 1.0)

	# Draw health bar above king
	var bar_width = 64
	var bar_height = 8
	var bar_pos = Vector2(-bar_width / 2, -50)

	draw_rect(Rect2(bar_pos, Vector2(bar_width, bar_height)), Color.BLACK)
	draw_rect(Rect2(bar_pos, Vector2(bar_width * health_percent, bar_height)), Color.RED)
