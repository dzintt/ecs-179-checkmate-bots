extends Panel

var tower_type: String = "knight"
var tower_cost: int = 3


func _ready():
	if EventBus:
		EventBus.gold_changed.connect(_update_affordability)
	_update_affordability(0)
	var btn := get_node_or_null("Button")
	if btn:
		btn.focus_mode = Control.FOCUS_NONE


func _on_button_pressed():
	# Get placement_system the same way world_controller uses it
	var world = get_tree().current_scene
	if world:
		var placement_system = world.get_node_or_null("PlacementSystem")
		if placement_system and placement_system.has_method("start_placement"):
			placement_system.start_placement(tower_type, tower_cost)
			print("Selected ", tower_type, " for placement")


func _update_affordability(_gold_amount: int):
	if CurrencyManager:
		var can_afford = CurrencyManager.get_current_gold() >= tower_cost
		if can_afford:
			modulate = Color(1.0, 1.0, 1.0, 1.0)
		else:
			modulate = Color(0.5, 0.5, 0.5, 1.0)
