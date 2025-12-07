extends "res://scripts/core/enemy.gd"
class_name ShieldBot


func _ready():
	enemy_name = "Shield Bot"
	description = "Heavily armored robot with massive health. Slow but dangerous."

	move_speed = 60.0
	waypoint_threshold = 5.0

	# Set stats
	max_health = 260.0
	damage_to_base = 2
	currency_reward = 20
	attack_interval = 1.0

	# Set enemy type
	enemy_class = "shield"
	color = Color("dimgray")
	preset = EnemyPreset.SHIELD_GUARD

	super._ready()
	print("Shield Bot spawned")
