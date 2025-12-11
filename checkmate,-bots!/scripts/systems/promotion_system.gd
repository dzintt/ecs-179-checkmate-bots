extends Node
class_name PromotionSystem

## Handles pawn promotion flow: tracking movement, readiness, selection, and swapping.

var promotion_key := KEY_H
var promotion_options := {
	KEY_1: "queen",
	KEY_2: "rook",
	KEY_3: "bishop",
	KEY_4: "knight",
}

var promotion_select_mode: bool = false
var promotion_pending: PawnTower = null
var _ready_pawns: Array[PawnTower] = []
var _tower_container: Node2D = null


func set_tower_container(container: Node2D) -> void:
	_tower_container = container


func handle_input(event: InputEvent) -> bool:
	if not event is InputEventKey or not event.pressed:
		return false
	return _handle_key(event as InputEventKey)


func track_pawn_move(pawn: PawnTower, old_pos: Vector2i, new_pos: Vector2i) -> void:
	if pawn == null or not is_instance_valid(pawn):
		return
	var distance = abs(new_pos.x - old_pos.x) + abs(new_pos.y - old_pos.y)
	if distance <= 0:
		return
	if pawn.add_movement_progress(distance):
		_mark_pawn_ready(pawn)


func get_status_text() -> String:
	var pawn := _ready_pawn_under_mouse()
	if pawn == null:
		pawn = _first_valid_ready_pawn()

	if promotion_select_mode and promotion_pending != null and is_instance_valid(promotion_pending):
		return (
			"\nPromotion: pawn at %s -> 1=Queen 2=Rook 3=Bishop 4=Knight"
			% str(promotion_pending.grid_position)
		)

	if pawn != null:
		return "\nReady pawn at %s. Hover it, press H, then pick 1/2/3/4." % str(pawn.grid_position)

	return ""


func _handle_key(event: InputEventKey) -> bool:
	if event.keycode == promotion_key:
		_begin_promotion_selection()
		return true

	if promotion_select_mode and promotion_pending != null and is_instance_valid(promotion_pending):
		if promotion_options.has(event.keycode):
			var target_type: String = promotion_options[event.keycode]
			_promote_pending_pawn(target_type)
			return true
		if event.keycode == KEY_ESCAPE:
			_cancel_promotion_selection(false)
			return true

	return false


func _begin_promotion_selection():
	var pawn := _ready_pawn_under_mouse()
	if pawn == null:
		print("No pawn ready at cursor. Hover a ready pawn and press H to promote.")
		return

	promotion_pending = pawn
	promotion_select_mode = true
	print(
		"Promote pawn at ",
		pawn.grid_position,
		". Press 1=Queen, 2=Rook, 3=Bishop, 4=Knight to pick."
	)


func _promote_pending_pawn(target_type: String):
	if promotion_pending == null or not is_instance_valid(promotion_pending):
		_cancel_promotion_selection()
		return

	_promote_pawn_to_type(promotion_pending, target_type)
	_cancel_promotion_selection()


func _cancel_promotion_selection(update_label: bool = true):
	promotion_select_mode = false
	promotion_pending = null
	if update_label:
		# Caller can refresh UI.
		pass


func _ready_pawn_under_mouse() -> PawnTower:
	if _tower_container == null:
		return null
	var cam := get_viewport().get_camera_2d()
	if cam == null:
		return null
	var grid_pos = GridSystem.world_to_grid(cam.get_global_mouse_position())
	var tower := _tower_at_grid(grid_pos)
	if tower is PawnTower and tower.is_promotion_ready():
		return tower
	return null


func _first_valid_ready_pawn() -> PawnTower:
	var filtered: Array[PawnTower] = []
	var first_valid: PawnTower = null
	for pawn in _ready_pawns:
		if pawn != null and is_instance_valid(pawn) and pawn.is_promotion_ready():
			if first_valid == null:
				first_valid = pawn
			filtered.append(pawn)
	_ready_pawns = filtered
	return first_valid


func _mark_pawn_ready(pawn: PawnTower):
	if pawn == null or not is_instance_valid(pawn):
		return
	if not _ready_pawns.has(pawn):
		_ready_pawns.append(pawn)
	if promotion_pending == null or not is_instance_valid(promotion_pending):
		promotion_pending = pawn
	print("Pawn at ", pawn.grid_position, " is ready for promotion.")


func _promote_pawn_to_type(pawn: PawnTower, target_type: String):
	if pawn == null or not is_instance_valid(pawn):
		return

	var scene_path := "res://scenes/towers/%s.tscn" % target_type
	if not ResourceLoader.exists(scene_path):
		print("Promotion failed: missing scene for ", target_type)
		return

	var grid_pos := pawn.grid_position
	pawn.clear_promotion_state()
	_ready_pawns.erase(pawn)
	pawn.queue_free()

	var tower_scene: PackedScene = load(scene_path)
	if tower_scene == null:
		print("Promotion failed: could not load ", scene_path)
		return

	var new_tower = tower_scene.instantiate()
	if new_tower == null:
		print("Promotion failed: instantiate returned null for ", target_type)
		return

	new_tower.global_position = GridSystem.grid_to_world(grid_pos)

	if _tower_container:
		_tower_container.add_child(new_tower)
	GridSystem.occupy_tile(grid_pos)
	print("Pawn promoted to ", target_type, " at ", grid_pos)


func _tower_at_grid(grid_pos: Vector2i) -> Tower:
	if _tower_container == null:
		return null
	for child in _tower_container.get_children():
		if child is Tower:
			var t: Tower = child
			if t.grid_position == grid_pos:
				return t
	return null
