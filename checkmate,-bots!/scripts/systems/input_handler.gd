extends Node

## Input Handler - Centralized input processing
## Detects clicks on towers and empty tiles

signal tower_clicked(tower: Node)
signal empty_tile_clicked(position: Vector2)


func _input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_handle_left_click(event.position)


## Handle left mouse click
func _handle_left_click(screen_pos: Vector2):
	var world_pos = get_viewport().get_camera_2d().get_global_mouse_position()

	# TODO: Raycast to check for tower clicks
	# For now, just emit empty tile click
	empty_tile_clicked.emit(world_pos)

	# Example of how tower detection would work:
	# var space_state = get_world_2d().direct_space_state
	# var query = PhysicsPointQueryParameters2D.new()
	# query.position = world_pos
	# query.collision_mask = 1  # Tower layer
	# var result = space_state.intersect_point(query)
	# if result.size() > 0:
	#     var tower = result[0].collider
	#     tower_clicked.emit(tower)
