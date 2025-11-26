extends Node

## Wave Manager - Wave progression and enemy spawning
## Singleton accessible via WaveManager
## Controls wave flow, enemy spawning, difficulty scaling

var current_wave: int = 0
var max_waves: int = 10
var wave_in_progress: bool = false
var enemies_alive: int = 0
var wave_definitions: Array = []  # Array[WaveDefinition] when resource is created

func _ready():
	print("WaveManager initialized")

	# Connect to EventBus signals
	EventBus.enemy_died.connect(_on_enemy_died)
	EventBus.enemy_reached_base.connect(_on_enemy_reached_base)

	# TODO: Load wave definitions from resources/waves/
	_load_wave_definitions()


## Load wave definitions from resource files
func _load_wave_definitions():
	# TODO: Implement loading from .tres files
	print("TODO: Load wave definitions from resources/waves/")
	pass


## Start the next wave
func start_wave():
	if wave_in_progress:
		print("Wave already in progress!")
		return

	if current_wave >= max_waves:
		print("All waves completed!")
		EventBus.all_waves_completed.emit()
		GameManager.end_game(true)  # Victory
		return

	current_wave += 1
	wave_in_progress = true
	EventBus.wave_started.emit(current_wave)
	print("Wave ", current_wave, " started!")

	# TODO: Spawn enemies from wave definition
	_spawn_wave_enemies()


## Spawn enemies for current wave
func _spawn_wave_enemies():
	# TODO: Implement enemy spawning based on WaveDefinition
	# For now, just placeholder
	enemies_alive = 5  # Placeholder
	print("TODO: Spawn ", enemies_alive, " enemies")
	pass


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
func _on_enemy_died(enemy: Node, gold_reward: int):
	enemies_alive -= 1
	print("Enemy died. Remaining: ", enemies_alive)
	_check_wave_completion()


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
