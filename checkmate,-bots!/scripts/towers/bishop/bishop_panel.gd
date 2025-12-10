extends Panel

var tower_type: String = "bishop"
var tower_cost: int = 3
const TOWER_SCENE_PATH := "res://scenes/towers/"
const TOWER_DESC := "Attacks all tiles in diagonal lines. Fires projectiles at medium speed."
const DamageEngine := preload("res://scripts/core/damage_engine.gd")
const Enemy := preload("res://scripts/core/enemy.gd")
const ENEMY_PRESET_LABELS := {
	Enemy.EnemyPreset.BASIC_PAWN: "Pawn",
	Enemy.EnemyPreset.LOOT_RUNNER: "Runner",
	Enemy.EnemyPreset.SHIELD_GUARD: "Shield",
	Enemy.EnemyPreset.CASTER: "Caster",
	Enemy.EnemyPreset.BOMBER: "Bomber",
}
var _button: Button


func _ready():
	if EventBus:
		EventBus.gold_changed.connect(_update_affordability)
	_update_affordability(0)
	_button = get_node_or_null("Button")
	if _button:
		_button.focus_mode = Control.FOCUS_NONE
	_set_tooltip()


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


func _set_tooltip():
	var stats = _fetch_stats()
	var header = tower_type.capitalize()
	if stats.is_empty():
		var txt = "%s\n%s" % [header, TOWER_DESC]
		_set_tooltip_text(txt)
		return
	var mods = _modifiers_text()
	var txt = (
		"%s\n%s\nDamage: %.1f | Cooldown: %.2fs%s"
		% [
			header,
			TOWER_DESC,
			stats["dmg"],
			stats["cd"],
			mods,
		]
	)
	_set_tooltip_text(txt)


func _set_tooltip_text(txt: String):
	tooltip_text = txt
	if _button:
		_button.tooltip_text = txt


func _fetch_stats() -> Dictionary:
	var scene_path = TOWER_SCENE_PATH + tower_type + ".tscn"
	if not ResourceLoader.exists(scene_path):
		return {}
	var scene: PackedScene = load(scene_path)
	if scene == null:
		return {}
	var inst = scene.instantiate()
	if inst == null or not (inst is Tower):
		if inst is Node:
			inst.queue_free()
		return {}
	var t: Tower = inst
	var data = {"dmg": t.attack_damage, "cd": t.attack_cooldown, "proj": t.projectile_speed}
	inst.queue_free()
	return data


func _modifiers_text() -> String:
	var factors: Dictionary = DamageEngine.TYPE_FACTORS.get(tower_type, {})
	if factors.is_empty():
		return ""
	var parts: Array[String] = []
	for preset in factors.keys():
		var label = ENEMY_PRESET_LABELS.get(preset, str(preset))
		var mult: float = factors[preset]
		parts.append("%s %.1fx" % [label, mult])
	parts.sort()
	return "\n" + "Modifiers: " + ", ".join(parts)
