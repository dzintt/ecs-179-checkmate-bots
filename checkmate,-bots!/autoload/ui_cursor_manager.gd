extends Node

## Ensures all buttons use the pointing hand cursor on hover.


func _ready():
	_apply_to_subtree(get_tree().get_root())
	get_tree().node_added.connect(_on_node_added)


func _on_node_added(node: Node):
	_apply_to_subtree(node)


func _apply_to_subtree(node: Node):
	_apply_cursor(node)
	for child in node.get_children():
		_apply_to_subtree(child)


func _apply_cursor(node: Node):
	if node is BaseButton:
		node.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
