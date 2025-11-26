extends Node

var current_wave: int = 0
var max_waves: int = 10
var wave_in_progress: bool = false
var enemies_alive: int = 0
var wave_definitions: Array = []
var path_manager: PathManager = null
var spawn_parent: Node = null

const ENEMY_SCENE = preload("res://scenes/enemies/test_enemy.tscn")

func _ready():
	print("WaveManager initialized")

	EventBus.enemy_died.connect(_on_enemy_died)
	EventBus.enemy_reached_base.connect(_on_enemy_reached_base)

	_load_wave_definitions()


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
	
	wave_definitions.append(_create_wave(1, [
		{"direction": "north", "count": 5, "delay": 1.0}
	]))
	
	wave_definitions.append(_create_wave(2, [
		{"direction": "south", "count": 7, "delay": 0.9}
	]))
	
	wave_definitions.append(_create_wave(3, [
		{"direction": "east", "count": 8, "delay": 0.8}
	]))
	
	wave_definitions.append(_create_wave(4, [
		{"direction": "west", "count": 8, "delay": 0.8}
	]))
	
	wave_definitions.append(_create_wave(5, [
		{"direction": "north", "count": 6, "delay": 0.8},
		{"direction": "south", "count": 6, "delay": 0.8}
	]))
	
	wave_definitions.append(_create_wave(6, [
		{"direction": "east", "count": 7, "delay": 0.7},
		{"direction": "west", "count": 7, "delay": 0.7}
	]))
	
	wave_definitions.append(_create_wave(7, [
		{"direction": "north", "count": 6, "delay": 0.6},
		{"direction": "east", "count": 6, "delay": 0.6},
		{"direction": "south", "count": 6, "delay": 0.6}
	]))
	
	wave_definitions.append(_create_wave(8, [
		{"direction": "north", "count": 6, "delay": 0.5},
		{"direction": "east", "count": 6, "delay": 0.5},
		{"direction": "south", "count": 6, "delay": 0.5},
		{"direction": "west", "count": 6, "delay": 0.5}
	]))
	
	wave_definitions.append(_create_wave(9, [
		{"direction": "north", "count": 8, "delay": 0.4},
		{"direction": "east", "count": 8, "delay": 0.4},
		{"direction": "south", "count": 8, "delay": 0.4},
		{"direction": "west", "count": 8, "delay": 0.4}
	]))
	
	wave_definitions.append(_create_wave(10, [
		{"direction": "north", "count": 10, "delay": 0.3},
		{"direction": "east", "count": 10, "delay": 0.3},
		{"direction": "south", "count": 10, "delay": 0.3},
		{"direction": "west", "count": 10, "delay": 0.3}
	]))


func _create_wave(wave_num: int, spawn_data: Array) -> Dictionary:
	return {
		"wave_number": wave_num,
		"spawn_data": spawn_data
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
		
		enemies_alive += count
		_spawn_enemies_from_direction(direction, count, delay)
	
	print("Wave ", current_wave, " spawning ", enemies_alive, " enemies")


func _spawn_enemies_from_direction(direction: String, count: int, delay: float):
	if path_manager == null or spawn_parent == null:
		return
	
	for i in range(count):
		if i > 0:
			await get_tree().create_timer(delay).timeout
		
		var enemy = ENEMY_SCENE.instantiate()
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
	if wave_in_progress and enemies_alive <= 0:
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
