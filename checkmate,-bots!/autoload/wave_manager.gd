extends Node

var current_wave: int = 0
var max_waves: int = 20
var wave_in_progress: bool = false
var enemies_alive: int = 0
var wave_definitions: Array = []
var path_manager: PathManager = null
var spawn_parent: Node = null
var _cancel_spawns: bool = false
var active_portals: Dictionary = {}

const PortalEffectScene := preload("res://scenes/effects/portal_effect.tscn")
const EnemyFactoryClass := preload("res://scripts/systems/enemy_factory.gd")
var enemy_factory = null


func _ready():
	print("WaveManager initialized")

	EventBus.enemy_died.connect(_on_enemy_died)
	EventBus.enemy_reached_base.connect(_on_enemy_reached_base)

	if enemy_factory == null:
		enemy_factory = EnemyFactoryClass.new()
	enemy_factory.register_default_specs()
	_load_wave_definitions()


func _process(_delta):
	# Failsafe: if a wave is in progress and there are no enemies left under the spawn parent,
	# ensure the wave completes.
	_check_wave_completion()


func initialize(path_mgr: PathManager, spawn_node: Node):
	path_manager = path_mgr
	spawn_parent = spawn_node
	print("WaveManager initialized with PathManager and spawn parent")


func _load_wave_definitions():
	_create_procedural_waves()
	print("Loaded ", wave_definitions.size(), " wave definitions")


## Start the next wave
func start_wave():
	if wave_in_progress:
		print("Wave already in progress!")
		return

	if current_wave >= max_waves:
		print("All waves completed!")
		EventBus.all_waves_completed.emit()
		GameManager.end_game(true)
		return

	_cancel_spawns = false
	current_wave += 1
	wave_in_progress = true
	EventBus.wave_started.emit(current_wave)
	print("Wave ", current_wave, " started!")

	_spawn_wave_enemies()


func _create_procedural_waves():
	wave_definitions.clear()
	if enemy_factory == null:
		enemy_factory = EnemyFactoryClass.new()
		enemy_factory.register_default_specs()
	var base_score: float = 2.0
	var increment: float = 2.0

	for i in range(max_waves):
		var wave_number: int = i + 1
		var target: float = base_score + increment * i
		var allowed_ids: Array[String] = _allowed_ids_for_wave(target)
		var min_enemies: int = 1 + int(floor(i / 2.0))
		var max_enemies_for_wave: int = 6 + i
		var delay_floor: float = lerp(1.0, 0.4, float(i) / float(max_waves - 1))
		var wave_spec := EnemyFactoryClass.WaveSpec.new(
			wave_number,
			target,
			min_enemies,
			max_enemies_for_wave,
			allowed_ids,
			_directions_for_wave(wave_number),
			Vector2(delay_floor, delay_floor + 0.35),
			0.0,
			lerp(-0.25, 0.75, float(i) / float(max_waves - 1))
		)
		wave_definitions.append(enemy_factory.generate_wave(wave_spec))


func _allowed_ids_for_wave(target_score: float) -> Array[String]:
	var ids: Array[String] = []
	if target_score >= 1.0:
		ids.append("pawn")
	if target_score >= 2.0:
		ids.append("runner")
	if target_score >= 3.0:
		ids.append("caster")
	if target_score >= 4.0:
		ids.append("bomber")
	if target_score >= 5.0:
		ids.append("shield")
	return ids


func _directions_for_wave(wave_number: int) -> Array[String]:
	# Predefined progression: start single-lane, then expand pairs, then all.
	var progression = []
	progression.append(["north", "north2"])  # 1: top
	progression.append(["east", "east2"])  # 2: right
	progression.append(["south", "south2"])  # 3: bottom
	progression.append(["west", "west2"])  # 4: left
	progression.append(["north", "north2", "east", "east2"])  # 5: top + right
	progression.append(["east", "east2", "south", "south2"])  # 6: right + bottom
	progression.append(["south", "south2", "west", "west2"])  # 7: bottom + left
	progression.append(["west", "west2", "north", "north2"])  # 8: left + top
	progression.append(["north", "north2", "east", "east2", "south", "south2"])  # 9: top/right/bottom
	progression.append(["east", "east2", "south", "south2", "west", "west2"])  # 10: right/bottom/left
	progression.append(["south", "south2", "west", "west2", "north", "north2"])  # 11: bottom/left/top
	progression.append(["west", "west2", "north", "north2", "east", "east2"])  # 12: left/top/right
	progression.append(["north", "north2", "east", "east2", "south", "south2", "west", "west2"])  # 13+: all directions

	if wave_number <= progression.size():
		var dirs: Array[String] = []
		dirs.assign(progression[wave_number - 1])
		dirs.shuffle()
		return dirs

	var fallback: Array[String] = []
	fallback.assign(progression[progression.size() - 1])
	fallback.shuffle()
	return fallback


func _spawn_wave_enemies():
	if path_manager == null or spawn_parent == null:
		push_error("WaveManager not properly initialized! Call initialize() first.")
		return

	if current_wave <= 0 or current_wave > wave_definitions.size():
		push_error("Invalid wave number: ", current_wave)
		return

	var wave_def = wave_definitions[current_wave - 1]
	var spawn_data_array = wave_def["spawn_data"]

	_close_all_portals()
	_show_portals_for_wave(spawn_data_array)

	enemies_alive = 0

	for spawn_info in spawn_data_array:
		var direction = spawn_info["direction"]
		var count = spawn_info["count"]
		var delay = spawn_info["delay"]
		var enemy_type = "pawn"
		if spawn_info.has("type"):
			enemy_type = spawn_info["type"]

		enemies_alive += count
		_spawn_enemies_from_direction(direction, count, delay, enemy_type)

	print("Wave ", current_wave, " spawning ", enemies_alive, " enemies")


func _spawn_enemies_from_direction(direction: String, count: int, delay: float, enemy_type: String):
	for i in range(count):
		if i > 0:
			await get_tree().create_timer(delay).timeout

		if _cancel_spawns or spawn_parent == null or not is_instance_valid(spawn_parent):
			return

		var scene: PackedScene = enemy_factory.get_scene(enemy_type) if enemy_factory else null
		if scene == null:
			print(
				"Spawn failed: missing scene for type ",
				enemy_type,
				" - falling back and decrementing counter"
			)
			enemies_alive -= 1
			continue

		var enemy = scene.instantiate()
		if enemy == null:
			print("Spawn failed: could not instantiate enemy type ", enemy_type)
			enemies_alive -= 1
			continue

		if (
			_cancel_spawns
			or path_manager == null
			or spawn_parent == null
			or not is_instance_valid(spawn_parent)
		):
			return

		spawn_parent.add_child(enemy)

		var path: Array[Vector2] = path_manager.get_direction_path(direction)
		if enemy.has_method("set_path") and not path.is_empty():
			enemy.set_path(path)

		if enemy.has_signal("enemy_died"):
			enemy.enemy_died.connect(_on_enemy_instance_died)
		if enemy.has_signal("enemy_reached_end"):
			enemy.enemy_reached_end.connect(_on_enemy_instance_reached_end)
		EventBus.enemy_spawned.emit(enemy)


func _on_enemy_instance_died(enemy: Enemy):
	EventBus.enemy_died.emit(enemy, enemy.currency_reward)


func _on_enemy_instance_reached_end(enemy: Enemy):
	EventBus.enemy_reached_base.emit(enemy, enemy.damage_to_base)


## End the current wave
func end_wave():
	if not wave_in_progress:
		return

	wave_in_progress = false
	_close_all_portals()
	EventBus.wave_completed.emit(current_wave)
	print("Wave ", current_wave, " completed!")

	# Check victory condition
	if current_wave >= max_waves:
		EventBus.all_waves_completed.emit()
		GameManager.end_game(true)


## Check if wave is complete
func _check_wave_completion():
	if not wave_in_progress:
		return

	# If the enemy container is empty, sync the counter
	if spawn_parent != null and spawn_parent.get_child_count() == 0:
		enemies_alive = 0

	if enemies_alive <= 0:
		end_wave()


# Event handlers
@warning_ignore("unused_parameter")
func _on_enemy_died(enemy: Node, gold_reward: int):
	enemies_alive -= 1
	print("Enemy died. Remaining: ", enemies_alive)
	_check_wave_completion()


@warning_ignore("unused_parameter")
func _on_enemy_reached_base(enemy: Node, damage: int):
	enemies_alive -= 1
	print("Enemy reached base. Remaining: ", enemies_alive)
	_check_wave_completion()


## Get current wave number
func get_current_wave() -> int:
	return current_wave


func get_wave_summary(wave_number: int) -> String:
	if wave_number <= 0 or wave_number > wave_definitions.size():
		return "No wave data"

	var wave_def = wave_definitions[wave_number - 1]
	var spawn_data: Array = wave_def.get("spawn_data", [])
	if spawn_data.is_empty():
		return "No spawns"

	var buckets := {}
	for spawn_info in spawn_data:
		var etype: String = spawn_info.get("type", "")
		var dir: String = spawn_info.get("direction", "")
		var key := "%s|%s" % [etype, dir]
		var count: int = int(spawn_info.get("count", 1))
		buckets[key] = buckets.get(key, 0) + count

	var parts: Array[String] = []
	for key in buckets.keys():
		var split = key.split("|")
		if split.size() != 2:
			continue
		var etype = split[0]
		var dir = split[1]
		parts.append("%s x%d (%s)" % [etype, buckets[key], dir])

	parts.sort()
	return ", ".join(parts)


## Check if a wave is in progress
func is_wave_active() -> bool:
	return wave_in_progress


## Reset waves to initial state
func reset_waves():
	current_wave = 0
	wave_in_progress = false
	enemies_alive = 0
	_cancel_spawns = true
	_close_all_portals()
	# Clear any spawned enemies
	get_tree().call_group("enemies", "queue_free")
	_load_wave_definitions()
	print("Waves reset")


func _show_portals_for_wave(spawn_data_array: Array):
	if path_manager == null or spawn_parent == null:
		return

	var directions := {}
	for spawn_info in spawn_data_array:
		if spawn_info.has("direction"):
			directions[spawn_info["direction"]] = true

	for direction in directions.keys():
		if active_portals.has(direction) and is_instance_valid(active_portals[direction]):
			continue

		var start_pos: Vector2 = path_manager.get_start_position(direction)
		var portal: Node2D = PortalEffectScene.instantiate()
		spawn_parent.add_child(portal)
		portal.global_position = start_pos
		active_portals[direction] = portal


func _close_all_portals():
	for direction in active_portals.keys():
		var portal: PortalEffect = active_portals[direction]
		if portal and is_instance_valid(portal):
			portal.close_and_free()
	active_portals.clear()
