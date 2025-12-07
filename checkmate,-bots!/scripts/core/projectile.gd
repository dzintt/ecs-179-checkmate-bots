extends Node2D

## Homing projectile that tracks a target enemy and applies damage once.

@export var speed: float = 600.0
@export var hit_radius: float = 12.0
@export var max_lifetime: float = 3.0

var damage: float = 0.0
var tower_class: String = ""
var target: Enemy

var _lifetime: float = 0.0
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D


func _ready():
	if anim:
		anim.play("fly")
	queue_redraw()


func configure(
	damage_value: float, tower_class_value: String, target_enemy: Enemy, projectile_speed: float
):
	damage = damage_value
	tower_class = tower_class_value
	target = target_enemy
	speed = projectile_speed


func _physics_process(delta: float):
	_lifetime += delta
	if _lifetime >= max_lifetime:
		queue_free()
		return

	if not _is_target_valid():
		queue_free()
		return

	var target_pos: Vector2 = target.global_position
	var to_target: Vector2 = target_pos - global_position
	var distance: float = to_target.length()

	if distance <= hit_radius:
		_apply_hit()
		return

	var direction: Vector2 = to_target / max(distance, 0.001)
	rotation = direction.angle()
	global_position += direction * speed * delta


func _apply_hit():
	if _is_target_valid():
		target.take_damage(damage, tower_class)
	queue_free()


func _is_target_valid() -> bool:
	return target != null and is_instance_valid(target) and target.is_alive


func _draw():
	# Only draw placeholder if no animated sprite is present
	if anim == null:
		draw_circle(Vector2.ZERO, 6, Color(1, 0.85, 0.2, 0.9))
		draw_circle(Vector2.ZERO, 6, Color(0, 0, 0, 0.8), false, 1.5)
