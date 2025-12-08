extends "res://scripts/core/tower.gd"

class_name KingBase

## King Base - Player's main base (must protect)
## Attacks: 1 tile in all 8 directions
## Has health pool - if destroyed, player loses

@export var max_health: int = 39
@export var footprint_tiles: int = 2  # Occupies a 2x2 footprint on the grid
var current_health: int

signal king_health_changed(current: int, max: int)
signal king_died


func _ready():
	tower_class = "king"
	tower_name = "King"
	description = "This is your base, please protect at all costs! Attacks in 1 tile in all directions"

	base_cost = 0
	upgrade_cost = 0

	attack_damage = 4.0
	attack_cooldown = 0.5
	projectile_speed = 0.0

	footprint_tiles = max(1, footprint_tiles)
	grid_position = _compute_center_grid_position()
	current_health = max_health

	EventBus.enemy_reached_base.connect(_on_enemy_reached_base)

	super._ready()
	print("King initialized with ", current_health, " health")


## King attack pattern: 1 tile in all 8 directions (adjacent tiles)
func get_attack_pattern() -> Array[Vector2i]:
	var pattern: Array[Vector2i] = []

	# All 8 adjacent tiles
	pattern.append(Vector2i(1, 0))  # Right
	pattern.append(Vector2i(-1, 0))  # Left
	pattern.append(Vector2i(0, 1))  # Down
	pattern.append(Vector2i(0, -1))  # Up
	pattern.append(Vector2i(1, 1))  # Bottom-right
	pattern.append(Vector2i(1, -1))  # Top-right
	pattern.append(Vector2i(-1, 1))  # Bottom-left
	pattern.append(Vector2i(-1, -1))  # Top-left

	return pattern


func _on_enemy_reached_base(_enemy: Node, damage: int):
	take_damage(damage)


func take_damage(damage: int):
	current_health -= damage
	current_health = max(0, current_health)

	king_health_changed.emit(current_health, max_health)
	EventBus.king_damaged.emit(current_health, max_health)
	queue_redraw()

	print("King damaged! Health: ", current_health, "/", max_health)

	if current_health <= 0:
		_die()


## King is destroyed - game over
func _die():
	king_died.emit()
	EventBus.king_destroyed.emit()
	GameManager.end_game(false)  # Player loses
	print("King destroyed! Game Over!")


func _compute_center_grid_position() -> Vector2i:
	# Round to nearest tile so the attack pattern is centered over the 2x2 footprint
	var tile_size = float(GridSystem.TILE_SIZE)
	var grid_pos_float = Vector2(global_position.x / tile_size, global_position.y / tile_size)
	return Vector2i(round(grid_pos_float.x), round(grid_pos_float.y))
