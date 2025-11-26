extends Resource
class_name TowerStats

## Tower Stats Resource - Defines tower properties
## Data-driven approach for tower configuration

@export var tower_name: String = "Tower"
@export var base_cost: int = 50
@export var upgrade_cost: int = 75
@export var attack_damage: float = 20.0
@export var attack_cooldown: float = 1.0
@export var projectile_speed: float = 300.0
@export var attack_pattern: AttackPattern
@export var icon: Texture2D
@export var description: String = "A basic tower"

# TODO: Add sprite/texture when ready
