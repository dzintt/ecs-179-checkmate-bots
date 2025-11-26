extends Resource
class_name EnemyStats

## Enemy Stats Resource - Defines enemy properties
## Data-driven approach for enemy configuration

@export var enemy_name: String = "Robot"
@export var max_health: float = 100.0
@export var move_speed: float = 100.0
@export var damage_to_base: int = 1
@export var currency_reward: int = 10
@export var color: Color = Color.RED
@export var description: String = "A basic robot enemy"

# TODO: Add sprite/texture when ready
