extends "res://scripts/core/enemy.gd"
class_name CourierBot


func _ready():
	enemy_name = "Courier Bot"
	description = "Fast courier carrying valuable loot. High reward if stopped!"

	move_speed = 220.0
	waypoint_threshold = 5.0

	max_health = 30.0
	damage_to_base = 1
	currency_reward = 10  # Changable
	attack_interval = 0.0

	# Set enemy type
	enemy_class = "runner"
	color = Color("gold")
	preset = EnemyPreset.LOOT_RUNNER

	super._ready()
	print("Courier Bot spawned")


func _reach_end_of_path():
	is_active = false
	# Suicide attack - hit once then disappear
	enemy_reached_end.emit(self)
	queue_free()
