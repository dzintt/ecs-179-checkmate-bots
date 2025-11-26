extends Node2D

class_name Tower

## Base tower class for chess-pattern based tower defense
## All towers use grid-based attack patterns (Pawn, Knight, Bishop, Rook, Queen, King)

@export_group("Tower Info")
@export var tower_name: String = "Tower"
@export var icon: Texture2D
@export var description: String = "A basic tower"
@export var tower_level: int = 1

@export_group("Costs")
@export var base_cost: int = 50
@export var upgrade_cost: int = 75

@export_group("Attack Properties")
## Damage dealt per attack
@export var attack_damage: float = 20.0
## Time between attacks in seconds
@export var attack_cooldown: float = 1.0
## Projectile speed (if using projectiles)
@export var projectile_speed: float = 300.0
@export var attack_pattern: AttackPattern

@export_group("Targeting")
## Targeting priority mode
@export_enum("First", "Last", "Closest", "Strongest", "Weakest") var targeting_mode: String = "First"

@export_group("Tower Type")
## Tower class (e.g., "pawn", "knight", "bishop", "rook", "queen", "king")
@export var tower_class: String = "basic"
## Enemy classes this tower can attack (empty = all)
@export var allowed_enemy_classes: Array[String] = []

var enemies_in_range: Array[Enemy] = []
var current_target: Enemy = null
var attack_timer: float = 0.0
var grid_position: Vector2i

signal tower_attacked(target: Enemy)
signal target_acquired(target: Enemy)
signal target_lost(target: Enemy)
signal tower_upgraded(new_level: int)


func _ready():
	# Calculate grid position from world position
	grid_position = GridSystem.world_to_grid(global_position)
	_setup_visual()


func _process(delta: float):
	_update_attack_timer(delta)
	_scan_for_enemies()
	_update_targeting()
	_attempt_attack()


## Override this in subclasses to define chess attack pattern
## Returns array of grid offsets that this tower can attack
func get_attack_pattern() -> Array[Vector2i]:
	# Base implementation - override in subclasses
	return []


## Scan for enemies in the tower's attack pattern
func _scan_for_enemies():
	enemies_in_range.clear()

	var attack_tiles = get_attack_pattern()
	if attack_tiles.is_empty():
		return

	# Get all enemies in the scene
	var enemy_container = get_node_or_null("../../EnemyContainer")
	if not enemy_container:
		return

	for enemy in enemy_container.get_children():
		if not enemy is Enemy or not enemy.is_alive:
			continue

		# Check if enemy is on one of our attack tiles
		var enemy_grid_pos = GridSystem.world_to_grid(enemy.global_position)

		for pattern_offset in attack_tiles:
			var attack_tile = grid_position + pattern_offset
			if enemy_grid_pos == attack_tile:
				# Check class restrictions
				if _can_attack_enemy(enemy):
					enemies_in_range.append(enemy)
				break


## Check if this tower can attack a specific enemy based on class restrictions
func _can_attack_enemy(enemy: Enemy) -> bool:
	# If no restrictions, can attack all
	if allowed_enemy_classes.is_empty():
		return true

	# Check if enemy class is in allowed list
	return allowed_enemy_classes.has(enemy.get_enemy_class())


## Update current target based on targeting priority
func _update_targeting():
	# Clean up dead/invalid enemies
	enemies_in_range = enemies_in_range.filter(func(e): return is_instance_valid(e) and e.is_alive)

	if enemies_in_range.is_empty():
		if current_target != null:
			target_lost.emit(current_target)
			current_target = null
		return

	# Select target based on priority mode
	var new_target = _select_target_by_priority()

	if new_target != current_target:
		if current_target != null:
			target_lost.emit(current_target)
		current_target = new_target
		if current_target != null:
			target_acquired.emit(current_target)


## Select the best target based on the targeting mode
func _select_target_by_priority() -> Enemy:
	if enemies_in_range.is_empty():
		return null

	match targeting_mode:
		"First":
			return _get_first_enemy()
		"Last":
			return _get_last_enemy()
		"Closest":
			return _get_closest_enemy()
		"Strongest":
			return _get_strongest_enemy()
		"Weakest":
			return _get_weakest_enemy()
		_:
			return enemies_in_range[0]


## Get the enemy furthest along their path (First targeting)
func _get_first_enemy() -> Enemy:
	var best_enemy: Enemy = null
	var best_progress: int = -1

	for enemy in enemies_in_range:
		if enemy.current_waypoint_index > best_progress:
			best_progress = enemy.current_waypoint_index
			best_enemy = enemy

	return best_enemy


## Get the enemy least far along their path (Last targeting)
func _get_last_enemy() -> Enemy:
	var best_enemy: Enemy = null
	var best_progress: int = 999999

	for enemy in enemies_in_range:
		if enemy.current_waypoint_index < best_progress:
			best_progress = enemy.current_waypoint_index
			best_enemy = enemy

	return best_enemy


## Get the closest enemy (Closest targeting)
func _get_closest_enemy() -> Enemy:
	var best_enemy: Enemy = null
	var best_distance: float = INF

	for enemy in enemies_in_range:
		var distance = global_position.distance_to(enemy.global_position)
		if distance < best_distance:
			best_distance = distance
			best_enemy = enemy

	return best_enemy


## Get the enemy with the most health (Strongest targeting)
func _get_strongest_enemy() -> Enemy:
	var best_enemy: Enemy = null
	var best_health: float = -1.0

	for enemy in enemies_in_range:
		if enemy.current_health > best_health:
			best_health = enemy.current_health
			best_enemy = enemy

	return best_enemy


## Get the enemy with the least health (Weakest targeting)
func _get_weakest_enemy() -> Enemy:
	var best_enemy: Enemy = null
	var best_health: float = INF

	for enemy in enemies_in_range:
		if enemy.current_health < best_health:
			best_health = enemy.current_health
			best_enemy = enemy

	return best_enemy


## Update the attack cooldown timer
func _update_attack_timer(delta: float):
	if attack_timer > 0:
		attack_timer -= delta


## Attempt to attack the current target
func _attempt_attack():
	if current_target == null or attack_timer > 0:
		return

	if not is_instance_valid(current_target) or not current_target.is_alive:
		current_target = null
		return

	_perform_attack()
	attack_timer = attack_cooldown


## Execute the attack on the current target
func _perform_attack():
	if current_target == null:
		return

	# Deal damage to target
	current_target.take_damage(attack_damage, tower_class)
	tower_attacked.emit(current_target)

	# TODO: Spawn projectile/visual effect here
	# TODO: Play attack sound here

	_show_attack_effect()


## Visual indication of attack (placeholder)
func _show_attack_effect():
	# Draw a line to the target temporarily
	queue_redraw()


## Upgrade this tower to the next level
func upgrade_tower():
	tower_level += 1

	# Increase stats (adjust multipliers as needed)
	attack_damage *= 1.2
	attack_cooldown *= 0.9

	tower_upgraded.emit(tower_level)
	queue_redraw()


## Setup placeholder visual (replace with sprite later)
func _setup_visual():
	queue_redraw()
