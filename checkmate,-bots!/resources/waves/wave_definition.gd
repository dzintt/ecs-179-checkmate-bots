extends Resource
class_name WaveDefinition

## Wave Definition Resource - Defines wave composition
## Specifies which enemies spawn, when, and from where

@export var wave_number: int = 1
@export var completion_bonus: int = 50
@export var enemy_spawns: Array[EnemySpawnData] = []

## Example: Create WaveDefinition with multiple EnemySpawnData entries
