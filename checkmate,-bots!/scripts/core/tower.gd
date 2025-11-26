extends Node2D
class_name Tower

## Base tower class with attack range and targeting priority
## Extend this for specific tower types (Bishop, Rook, Knight, etc.)

@export_group("Attack Properties")
## Attack range radius in pixels
@export var attack_range: float = 150.0
## Damage dealt per attack
@export var attack_damage: float = 20.0
## Time between attacks in seconds
@export var attack_cooldown: float = 1.0
## Projectile speed (if using projectiles)
@export var projectile_speed: float = 300.0

@export_group("Targeting")
## Targeting priority mode
@export_enum("First", "Last", "Closest", "Strongest", "Weakest") var targeting_mode: String = "First"

@export_group("Tower Type")
## Tower class (e.g., "bishop", "rook", "knight")
@export var tower_class: String = "basic"
## Enemy classes this tower can attack (empty = all)
@export var allowed_enemy_classes: Array[String] = []

@export_group("Upgrades")
## Current tower level
@export var tower_level: int = 1
## Cost to upgrade to next level
@export var upgrade_cost: int = 50


var enemies_in_range: Array[Enemy] = []
var current_target: Enemy = null
var attack_timer: float = 0.0
var range_area: Area2D = null

signal tower_attacked(target: Enemy)
signal target_acquired(target: Enemy)
signal target_lost(target: Enemy)
signal tower_upgraded(new_level: int)

func _ready():
	_setup_attack_range()
	_setup_visual()

func _process(delta: float):
	_update_attack_timer(delta)
	_update_targeting()
	_attempt_attack()

## Setup the Area2D that detects enemies in range
func _setup_attack_range():
	range_area = Area2D.new()
	range_area.name = "AttackRange"
	add_child(range_area)
	
	var collision_shape = CollisionShape2D.new()
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = attack_range
	collision_shape.shape = circle_shape
	range_area.add_child(collision_shape)
	
	# Connect signals
	range_area.body_entered.connect(_on_enemy_entered_range)
	range_area.body_exited.connect(_on_enemy_exited_range)
	
	# Set collision layers (adjust based on your project settings)
	range_area.collision_layer = 0
	range_area.collision_mask = 2  # Assuming enemies are on layer 2

## Update the attack range (useful for upgrades)
func set_attack_range(new_range: float):
	attack_range = new_range
	if range_area:
		var collision_shape = range_area.get_child(0) as CollisionShape2D
		if collision_shape and collision_shape.shape is CircleShape2D:
			(collision_shape.shape as CircleShape2D).radius = attack_range
	queue_redraw()

## Called when an enemy enters attack range
func _on_enemy_entered_range(body: Node2D):
	if body is Enemy:
		var enemy = body as Enemy
		
		# Check class restrictions
		if not _can_attack_enemy(enemy):
			return
		
		if not enemies_in_range.has(enemy):
			enemies_in_range.append(enemy)
			# Connect to enemy's died signal to remove from list
			if not enemy.enemy_died.is_connected(_on_enemy_died):
				enemy.enemy_died.connect(_on_enemy_died)

## Called when an enemy exits attack range
func _on_enemy_exited_range(body: Node2D):
	if body is Enemy:
		_remove_enemy_from_range(body as Enemy)

## Remove an enemy from the tracking list
func _remove_enemy_from_range(enemy: Enemy):
	if enemies_in_range.has(enemy):
		enemies_in_range.erase(enemy)
	
	if current_target == enemy:
		current_target = null
		target_lost.emit(enemy)

## Called when a tracked enemy dies
func _on_enemy_died(enemy: Enemy):
	_remove_enemy_from_range(enemy)

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
			# Target enemy furthest along the path
			return _get_first_enemy()
		"Last":
			# Target enemy least far along the path
			return _get_last_enemy()
		"Closest":
			# Target closest enemy
			return _get_closest_enemy()
		"Strongest":
			# Target enemy with most health
			return _get_strongest_enemy()
		"Weakest":
			# Target enemy with least health
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
	attack_range *= 1.1
	
	set_attack_range(attack_range)
	tower_upgraded.emit(tower_level)
	queue_redraw()

## Setup placeholder visual (replace with sprite later)
func _setup_visual():
	queue_redraw()
