extends CharacterBody2D
class_name Enemy

## Enemy that follows a designated path
## Adjust speed, health, and other properties in the inspector

@export_group("Enemy Info")
## Enemy display name
@export var enemy_name: String = "Robot"
## Visual representation color (placeholder until sprites added)
@export var color: Color = Color.RED
## Enemy description
@export var description: String = "A basic robot enemy"

@export_group("Movement")
## Speed at which the enemy moves along the path
@export var move_speed: float = 100.0
## How close the enemy needs to be to a waypoint before moving to the next one
@export var waypoint_threshold: float = 5.0

@export_group("Stats")
## Enemy health points
@export var max_health: float = 100.0
## Damage dealt when reaching the end of the path
@export var damage_to_base: int = 1
## Currency rewarded when killed
@export var currency_reward: int = 10
## How often non-suicide enemies damage the base once they reach it (seconds)
@export var attack_interval: float = 1.0

@export_group("Enemy Type")
## Enemy type/class (e.g., "ground", "flying", "armored")
@export var enemy_class: String = "ground"

## Preset types for different enemy kinds (used by damage_engine.gd)
enum EnemyPreset {
	BASIC_PAWN,    # Worker Bot
	LOOT_RUNNER,   # Courier Bot
	SHIELD_GUARD,  # Shield Bot
	CASTER,        # Artillery Bot
	BOMBER         # Bomb Drone
}

@export_group("Preset")
@export var preset: EnemyPreset = EnemyPreset.BASIC_PAWN

var current_health: float
var path_points: Array[Vector2] = []
var current_waypoint_index: int = 0
var is_active: bool = false
var is_alive: bool = true

## State for enemies that stay at the king and keep attacking
var _is_attacking_king: bool = false
var _attack_cooldown: float = 0.0

signal enemy_died(enemy: Enemy)
signal enemy_reached_end(enemy: Enemy)
signal health_changed(current: float, maximum: float)

func _ready():
	current_health = max_health
	_setup_visual()

func _physics_process(delta: float):
	if not is_alive:
		return

	# If this enemy has reached the king and is in attack mode,
	# it will periodically damage the base instead of moving.
	if _is_attacking_king:
		_attack_cooldown -= delta
		if _attack_cooldown <= 0.0:
			_attack_cooldown = attack_interval
			enemy_reached_end.emit(self)
		return

	if not is_active:
		return

	if path_points.is_empty() or current_waypoint_index >= path_points.size():
		_reach_end_of_path()
		return

	_move_along_path(delta)

## Set the path that this enemy should follow
func set_path(new_path: Array[Vector2]):
	path_points = new_path
	current_waypoint_index = 0
	if not path_points.is_empty():
		global_position = path_points[0]
	is_active = true

## Move towards the current waypoint
func _move_along_path(delta: float):
	var target_position = path_points[current_waypoint_index]
	var direction = (target_position - global_position).normalized()
	var distance_to_target = global_position.distance_to(target_position)

	# Check if we've reached the current waypoint
	if distance_to_target <= waypoint_threshold:
		current_waypoint_index += 1
		if current_waypoint_index >= path_points.size():
			_reach_end_of_path()
			return
			
		target_position = path_points[current_waypoint_index]
		direction = (target_position - global_position).normalized()

	# Move towards the waypoint
	velocity = direction * move_speed
	move_and_slide()

## Called when enemy reaches the end of the path
func _reach_end_of_path():
	is_active = false
	# Default behavior: stay at king and keep attacking
	_start_attacking_king()

## Start continuous attacks against the king/base
func _start_attacking_king():
	_is_attacking_king = true
	_attack_cooldown = 0.0  # immediate first hit
	# Deal damage to the King
	var king = get_tree().get_first_node_in_group("king")
	if king and king.has_method("take_damage"):
		king.take_damage(damage_to_base)

	enemy_reached_end.emit(self)
	queue_free()

## Apply damage to this enemy
func take_damage(damage: float, attacker_class: String = ""):
	if not is_alive:
		return

	# TODO: Implement class-based damage modifiers here
	# Example: if attacker_class == "bishop" and enemy_class == "armored": damage *= 1.5

	current_health -= damage
	health_changed.emit(current_health, max_health)
	queue_redraw()

	if current_health <= 0:
		_die()

## Called when enemy health reaches zero
func _die():
	is_alive = false
	is_active = false
	_is_attacking_king = false
	enemy_died.emit(self)
	# TODO: Play death animation/sound here
	queue_free()

## Get the enemy's current position (used by tower targeting)
func get_enemy_position() -> Vector2:
	return global_position

## Get the enemy's class type (used for class-based restrictions)
func get_enemy_class() -> String:
	return enemy_class

## Setup placeholder visual (replace with sprite later)
func _setup_visual():
	# Create a simple colored circle as placeholder
	var collision_shape = CollisionShape2D.new()
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = 16
	collision_shape.shape = circle_shape
	add_child(collision_shape)

	# Add visual indicator
	queue_redraw()

func _draw():
	# Draw a circle representing the enemy
	draw_circle(Vector2.ZERO, 16, color)
	draw_circle(Vector2.ZERO, 16, Color.BLACK, false, 2.0)

	# Draw health bar
	if is_alive:
		var health_percent = current_health / max_health
		var bar_width = 30
		var bar_height = 4
		var bar_pos = Vector2(-bar_width / 2, -25)

		# Background
		draw_rect(Rect2(bar_pos, Vector2(bar_width, bar_height)), Color.BLACK)
		# Health
		draw_rect(Rect2(bar_pos, Vector2(bar_width * health_percent, bar_height)), Color.GREEN)
