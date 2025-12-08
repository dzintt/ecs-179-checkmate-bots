extends Node

@export var camera_path: NodePath = NodePath("../Board/BoardCamera")
@export var placement_system_path: NodePath = NodePath("../PlacementSystem")
@export var zoom_step: float = 0.1
@export var min_zoom: float = 0.3
@export var max_zoom: float = 3.5
@export var pan_speed: float = 1.0

var _camera: Camera2D
var _placement_system: Node
var _dragging: bool = false
var _last_mouse_world: Vector2
var _touch_points := {}
var _touch_dragging: bool = false
var _last_touch_world: Vector2


func _ready():
	_camera = get_node_or_null(camera_path)
	if _camera:
		_camera.process_mode = Node.PROCESS_MODE_ALWAYS

	_placement_system = get_node_or_null(placement_system_path)

	set_process_unhandled_input(true)


func _unhandled_input(event: InputEvent) -> void:
	if get_tree().paused:
		return

	if event is InputEventMouseButton:
		_handle_mouse_button(event)
	elif event is InputEventMouseMotion:
		_handle_mouse_motion(event)
	elif event is InputEventMagnifyGesture:
		_handle_magnify(event)
	elif event is InputEventScreenTouch:
		_handle_screen_touch(event)
	elif event is InputEventScreenDrag:
		_handle_screen_drag(event)
	elif event is InputEventPanGesture:
		_handle_pan_gesture(event)


func _handle_mouse_button(event: InputEventMouseButton) -> void:
	if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
		_apply_zoom(1.0 - zoom_step)
	elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
		_apply_zoom(1.0 + zoom_step)
	elif event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed and not _is_placement_active():
			_dragging = true
			_last_mouse_world = _camera.get_global_mouse_position()
		else:
			_dragging = false


func _handle_mouse_motion(event: InputEventMouseMotion) -> void:
	if not _dragging or _is_placement_active() or _camera == null:
		return

	var current_world_before := _camera.get_global_mouse_position()
	var world_delta: Vector2 = (_last_mouse_world - current_world_before) * pan_speed
	_camera.global_position += world_delta

	_last_mouse_world = current_world_before + world_delta


func _apply_zoom(factor: float) -> void:
	if _camera == null:
		return

	var clamped = Vector2(
		clampf(_camera.zoom.x * factor, min_zoom, max_zoom),
		clampf(_camera.zoom.y * factor, min_zoom, max_zoom)
	)

	var before: Vector2 = _camera.get_global_mouse_position()
	_camera.zoom = clamped
	var after: Vector2 = _camera.get_global_mouse_position()
	_camera.global_position += before - after


func _is_placement_active() -> bool:
	if _placement_system == null:
		return false
	return bool(_placement_system.get("is_placing"))


func _handle_magnify(event: InputEventMagnifyGesture) -> void:
	if event.factor == 0:
		return
	_apply_zoom(event.factor)


func _handle_screen_touch(event: InputEventScreenTouch) -> void:
	if _is_placement_active():
		return

	if event.pressed:
		_touch_points[event.index] = event.position
	else:
		_touch_points.erase(event.index)

	_update_touch_drag_state()


func _handle_screen_drag(event: InputEventScreenDrag) -> void:
	if _is_placement_active() or _camera == null:
		return

	_touch_points[event.index] = event.position

	if not _touch_dragging:
		_update_touch_drag_state()
		return

	if _touch_points.size() < 2:
		_touch_dragging = false
		return

	var avg_screen := _average_touch_position()
	var current_world_before := _camera.get_viewport().get_camera_2d().unproject_position(
		avg_screen
	)
	var world_delta: Vector2 = (_last_touch_world - current_world_before) * pan_speed
	_camera.global_position += world_delta
	_last_touch_world = current_world_before + world_delta


func _update_touch_drag_state() -> void:
	if _touch_points.size() >= 2 and _camera != null:
		var avg_screen := _average_touch_position()
		_last_touch_world = _camera.get_viewport().get_camera_2d().unproject_position(avg_screen)
		_touch_dragging = true
	else:
		_touch_dragging = false


func _average_touch_position() -> Vector2:
	var sum := Vector2.ZERO
	for pos in _touch_points.values():
		sum += pos
	return sum / float(_touch_points.size())


func _handle_pan_gesture(event: InputEventPanGesture) -> void:
	if _camera == null or _is_placement_active():
		return
	var delta_world := event.delta * _camera.zoom * pan_speed * -1.0
	_camera.global_position += delta_world
