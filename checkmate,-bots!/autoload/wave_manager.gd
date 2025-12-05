extends Node

var current_wave: int = 0
var max_waves: int = 10
var wave_in_progress: bool = false
var enemies_alive: int = 0
var wave_definitions: Array = []
var path_manager: PathManager = null
var spawn_parent: Node = null

const ENEMY_SCENES := {
	"pawn": preload("res://scenes/enemies/basic_pawn.tscn"),
	"runner": preload("res://scenes/enemies/loot_runner.tscn"),
	"shield": preload("res://scenes/enemies/shielder.tscn"),
	"bomber": preload("res://scenes/enemies/bomber.tscn"),
	"caster": preload("res://scenes/enemies/caster.tscn")
}


func _ready():
	print("WaveManager initialized")

	EventBus.enemy_died.connect(_on_enemy_died)
	EventBus.enemy_reached_base.connect(_on_enemy_reached_base)

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

	current_wave += 1
	wave_in_progress = true
	EventBus.wave_started.emit(current_wave)
	print("Wave ", current_wave, " started!")

	_spawn_wave_enemies()


func _create_procedural_waves():
	wave_definitions.clear()

	# Wave 1: Basic pawns, single lane
	(
		wave_definitions
		. append(
			_create_wave(
				1,
				[
					{"direction": "north", "count": 8, "delay": 0.8, "type": "pawn"},
				]
			)
		)
	)

	# Wave 2: Pawns from opposite lane, slightly more
	(
		wave_definitions
		. append(
			_create_wave(
				2,
				[
					{"direction": "south", "count": 10, "delay": 0.75, "type": "pawn"},
				]
			)
		)
	)

	# Wave 3: One lanes, introduce fast runners
	(
		wave_definitions
		. append(
			_create_wave(
				3,
				[
					{"direction": "east", "count": 10, "delay": 0.7, "type": "pawn"},
					{"direction": "east", "count": 2, "delay": 1.0, "type": "runner"},
				]
			)
		)
	)

	# Wave 4: One lanes, add shield bots as mini-tanks
	(
		wave_definitions
		. append(
			_create_wave(
				4,
				[
					{"direction": "west", "count": 12, "delay": 0.65, "type": "pawn"},
					{"direction": "west", "count": 2, "delay": 1.3, "type": "shield"},
				]
			)
		)
	)

	# Wave 5: Opposite lanes, mix pawns and runners
	(
		wave_definitions
		. append(
			_create_wave(
				5,
				[
					{"direction": "north", "count": 10, "delay": 0.6, "type": "pawn"},
					{"direction": "south", "count": 4, "delay": 0.95, "type": "runner"},
				]
			)
		)
	)

	# Wave 6: East/West, add first bomber
	(
		wave_definitions
		. append(
			_create_wave(
				6,
				[
					{"direction": "east", "count": 12, "delay": 0.6, "type": "pawn"},
					{"direction": "west", "count": 12, "delay": 0.6, "type": "pawn"},
					{"direction": "west", "count": 1, "delay": 1.5, "type": "bomber"},
				]
			)
		)
	)

	# Wave 7: Three directions, more runners and a shield
	(
		wave_definitions
		. append(
			_create_wave(
				7,
				[
					{"direction": "north", "count": 10, "delay": 0.55, "type": "pawn"},
					{"direction": "east", "count": 6, "delay": 0.8, "type": "runner"},
					{"direction": "south", "count": 3, "delay": 1.2, "type": "shield"},
				]
			)
		)
	)

	# Wave 8: All directions, mix pawns, runners, bombers, shields
	(
		wave_definitions
		. append(
			_create_wave(
				8,
				[
					{"direction": "north", "count": 12, "delay": 0.5, "type": "pawn"},
					{"direction": "east", "count": 6, "delay": 0.75, "type": "runner"},
					{"direction": "south", "count": 4, "delay": 1.0, "type": "bomber"},
					{"direction": "west", "count": 4, "delay": 0.9, "type": "shield"},
				]
			)
		)
	)

	# Wave 9: All directions, introduce casters and more bombers
	(
		wave_definitions
		. append(
			_create_wave(
				9,
				[
					{"direction": "north", "count": 10, "delay": 0.45, "type": "pawn"},
					{"direction": "east", "count": 8, "delay": 0.65, "type": "runner"},
					{"direction": "south", "count": 3, "delay": 1.2, "type": "bomber"},
					{"direction": "west", "count": 3, "delay": 1.0, "type": "caster"},
				]
			)
		)
	)

	# Wave 10: Final wave - heavy mix, faster pacing
	(
		wave_definitions
		. append(
			_create_wave(
				10,
				[
					{"direction": "north", "count": 14, "delay": 0.4, "type": "pawn"},
					{"direction": "east", "count": 8, "delay": 0.6, "type": "runner"},
					{"direction": "south", "count": 4, "delay": 0.9, "type": "bomber"},
					{"direction": "west", "count": 4, "delay": 0.9, "type": "caster"},
					{"direction": "south", "count": 4, "delay": 1.0, "type": "shield"},
				]
			)
		)
	)


func _create_wave(wave_num: int, spawn_data: Array) -> Dictionary:
	return {
		"wave_number": wave_num,
		"spawn_data": spawn_data,
	}


func _spawn_wave_enemies():
	if path_manager == null or spawn_parent == null:
		push_error("WaveManager not properly initialized! Call initialize() first.")
		return

	if current_wave <= 0 or current_wave > wave_definitions.size():
		push_error("Invalid wave number: ", current_wave)
		return

	var wave_def = wave_definitions[current_wave - 1]
	var spawn_data_array = wave_def["spawn_data"]

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
	if path_manager == null or spawn_parent == null:
		return

	for i in range(count):
		if i > 0:
			await get_tree().create_timer(delay).timeout

		var scene: PackedScene = ENEMY_SCENES.get(enemy_type, ENEMY_SCENES.get("pawn"))
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

		spawn_parent.add_child(enemy)

		var path: Array[Vector2] = path_manager.get_direction_path(direction)
		if enemy.has_method("set_path") and not path.is_empty():
			enemy.set_path(path)

		if enemy.has_signal("enemy_died"):
			enemy.enemy_died.connect(_on_enemy_instance_died)
		if enemy.has_signal("enemy_reached_end"):
			enemy.enemy_reached_end.connect(_on_enemy_instance_reached_end)


func _on_enemy_instance_died(enemy: Enemy):
	EventBus.enemy_died.emit(enemy, enemy.currency_reward)


func _on_enemy_instance_reached_end(enemy: Enemy):
	EventBus.enemy_reached_base.emit(enemy, enemy.damage_to_base)


## End the current wave
func end_wave():
	if not wave_in_progress:
		return

	wave_in_progress = false
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


## Check if a wave is in progress
func is_wave_active() -> bool:
	return wave_in_progress


## Reset waves to initial state
func reset_waves():
	current_wave = 0
	wave_in_progress = false
	enemies_alive = 0
	# Clear any spawned enemies
	get_tree().call_group("enemies", "queue_free")
	print("Waves reset")
