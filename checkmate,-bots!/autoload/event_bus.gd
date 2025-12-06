extends Node
## Event Bus - Decoupled signal communication system
## Singleton accessible via EventBus
## Prevents tight coupling between game systems

# Enemy events
signal enemy_spawned(enemy: Node)
signal enemy_died(enemy: Node, gold_reward: int)
signal enemy_reached_base(enemy: Node, damage: int)
signal enemy_hit(enemy: Node, damage: float)

# Tower events
signal tower_placed(tower: Node, position: Vector2, cost: int)
signal tower_upgraded(tower: Node, new_level: int, cost: int)
signal tower_selected(tower: Node)
signal tower_deselected

# Wave events
signal wave_started(wave_number: int)
signal wave_completed(wave_number: int)
signal all_waves_completed

# King events
signal king_damaged(current_health: int, max_health: int)
signal king_destroyed

# Currency events
signal gold_changed(new_amount: int)


func _ready():
	print("EventBus initialized")
