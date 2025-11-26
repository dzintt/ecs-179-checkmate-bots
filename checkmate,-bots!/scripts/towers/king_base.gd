extends "res://scripts/core/tower.gd"
class_name KingBase

## King Base - Player's main base (must protect)
## Attacks: 1 tile in all 8 directions
## Has health pool - if destroyed, player loses

@export var max_health: int = 100
@export var footprint_tiles: int = 2  # Occupies a 2x2 footprint on the grid
var current_health: int

signal king_health_changed(current: int, max: int)
signal king_died()


func _ready():
	tower_class = "King"
	tower_name = "King"
	description = "This is your base, please protect at all costs! Attacks in 1 tile in all directions"
	
	base_cost = 0
	upgrade_cost = 0
	
	attack_damage = 9.0
	attack_cooldown = 0.5
	projectile_speed = 0.0
	
	
	footprint_tiles = max(1, footprint_tiles)
	grid_position = _compute_center_grid_position()
	current_health = max_health
	super._ready()
	print("King initialized with ", current_health, " health")


## King attack pattern: 1 tile in all 8 directions (adjacent tiles)
func get_attack_pattern() -> Array[Vector2i]:
	var pattern: Array[Vector2i] = []

	# All 8 adjacent tiles
	pattern.append(Vector2i(1, 0))      # Right
	pattern.append(Vector2i(-1, 0))     # Left
	pattern.append(Vector2i(0, 1))      # Down
	pattern.append(Vector2i(0, -1))     # Up
	pattern.append(Vector2i(1, 1))      # Bottom-right
	pattern.append(Vector2i(1, -1))     # Top-right
	pattern.append(Vector2i(-1, 1))     # Bottom-left
	pattern.append(Vector2i(-1, -1))    # Top-left

	return pattern


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
	# Placeholder: Draw a large red circle scaled to footprint
	var radius = GridSystem.TILE_SIZE * footprint_tiles / 2.0
	draw_circle(Vector2.ZERO, radius, Color.DARK_RED)
	draw_circle(Vector2.ZERO, radius, Color.BLACK, false, 3.0)

	# Draw health percentage as inner circle
	var health_percent = float(current_health) / float(max_health)
	var inner_radius = radius * 0.75
	draw_circle(Vector2.ZERO, inner_radius, Color(1, health_percent, health_percent, 0.7))

	# Draw health bar above king
	var bar_width = GridSystem.TILE_SIZE * footprint_tiles
	var bar_height = 8
	var bar_pos = Vector2(-bar_width / 2, -radius - 20)

	draw_rect(Rect2(bar_pos, Vector2(bar_width, bar_height)), Color.BLACK)
	draw_rect(Rect2(bar_pos, Vector2(bar_width * health_percent, bar_height)), Color.RED)


func _compute_center_grid_position() -> Vector2i:
	# Round to nearest tile so the attack pattern is centered over the 2x2 footprint
	var grid_pos_float = global_position / GridSystem.TILE_SIZE
	return Vector2i(round(grid_pos_float.x), round(grid_pos_float.y))
