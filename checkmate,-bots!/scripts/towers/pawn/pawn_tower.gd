extends "res://scripts/core/tower.gd"

class_name PawnTower

## Pawn Tower - Basic chess piece tower
## Attacks: 1 tile forward and 2 diagonal forward tiles
## Low cost, short range, good for early defense

@export var promotion_distance: int = 8
@export var promotion_highlight_color: Color = Color(1.0, 0.9, 0.2, 0.35)
@export var promotion_bounce_interval: float = 1.4

var tiles_moved_total: int = 0
var promotion_ready: bool = false
var _promotion_overlay: Polygon2D
var _promotion_bounce_timer: Timer


func _ready():
	tower_name = "Pawn"
	tower_class = "pawn"
	description = "Attacks with a wave animation like swinging a sword. Basic defensive tower."

	base_cost = 1
	upgrade_cost = 1

	attack_damage = 2.0
	attack_cooldown = 1.0
	projectile_speed = 0.0

	super._ready()
	_ensure_promotion_bounce_timer()
	print("Pawn tower ready at grid position: ", grid_position)


## Pawn attack pattern: 1 tile forward + 2 diagonal forward
func get_attack_pattern() -> Array[Vector2i]:
	var pattern: Array[Vector2i] = []

	pattern.append(Vector2i(0, -1))
	pattern.append(Vector2i(0, -2))
	pattern.append(Vector2i(0, 1))
	pattern.append(Vector2i(0, 2))
	pattern.append(Vector2i(-1, 0))
	pattern.append(Vector2i(-2, 0))
	pattern.append(Vector2i(1, 0))
	pattern.append(Vector2i(2, 0))

	return pattern


func add_movement_progress(tiles: int) -> bool:
	if tiles <= 0:
		return promotion_ready

	tiles_moved_total += tiles
	if not promotion_ready and tiles_moved_total >= promotion_distance:
		promotion_ready = true
		_start_promotion_ready_fx()
	elif promotion_ready:
		_update_promotion_overlay()

	return promotion_ready


func clear_promotion_state():
	promotion_ready = false
	if _promotion_bounce_timer:
		_promotion_bounce_timer.stop()
	if _promotion_overlay:
		_promotion_overlay.visible = false
		_promotion_overlay.global_position = GridSystem.grid_to_world(grid_position)


func is_promotion_ready() -> bool:
	return promotion_ready


func _start_promotion_ready_fx():
	_ensure_promotion_overlay()
	_update_promotion_overlay()
	_ensure_promotion_bounce_timer()
	if _promotion_bounce_timer:
		_promotion_bounce_timer.start()
	_play_attack_bounce()


func _ensure_promotion_overlay():
	if _promotion_overlay != null and is_instance_valid(_promotion_overlay):
		return

	_promotion_overlay = Polygon2D.new()
	_promotion_overlay.color = promotion_highlight_color
	var half := float(GridSystem.TILE_SIZE) / 2.0
	_promotion_overlay.polygon = PackedVector2Array(
		[
			Vector2(-half, -half),
			Vector2(half, -half),
			Vector2(half, half),
			Vector2(-half, half),
		]
	)

	_promotion_overlay.z_index = 3
	_promotion_overlay.visible = true
	var overlay_parent: Node = get_parent() if get_parent() != null else get_tree().current_scene
	if overlay_parent:
		overlay_parent.add_child(_promotion_overlay)
	_update_promotion_overlay()


func _update_promotion_overlay():
	if _promotion_overlay == null:
		return
	_promotion_overlay.visible = promotion_ready
	_promotion_overlay.global_position = GridSystem.grid_to_world(grid_position)


func _ensure_promotion_bounce_timer():
	if _promotion_bounce_timer != null:
		return
	_promotion_bounce_timer = Timer.new()
	_promotion_bounce_timer.wait_time = promotion_bounce_interval
	_promotion_bounce_timer.one_shot = false
	_promotion_bounce_timer.autostart = false
	add_child(_promotion_bounce_timer)
	_promotion_bounce_timer.timeout.connect(_on_promotion_bounce_timer_timeout)


func _on_promotion_bounce_timer_timeout():
	_play_attack_bounce()
