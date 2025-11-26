extends Resource
class_name EnemySpawnData

## Enemy Spawn Data - Defines how enemies spawn in a wave
## Used within WaveDefinition to specify enemy spawn details

@export var enemy_stats: EnemyStats
@export_enum("north", "east", "south", "west") var spawn_direction: String = "north"
@export var spawn_delay: float = 1.0  # Seconds between spawns
@export var count: int = 5  # Number of this enemy type to spawn
