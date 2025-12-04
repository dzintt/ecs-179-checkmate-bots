extends "res://scripts/core/enemy.gd"
class_name ArtilleryBot

func _ready():
	# Set enemy info
	enemy_name = "Artillery Bot"
	description = "Long-range artillery unit. Deals heavy damage to your base."
	
	move_speed = 80.0
	waypoint_threshold = 5.0
	
	max_health = 130.0
	damage_to_base = 4
	currency_reward = 22
	attack_interval = 1.0
	
	# Set enemy type
	enemy_class = "caster"
	color = Color("purple")
	preset = EnemyPreset.CASTER
	
	super._ready()
	print("Artillery Bot spawned")
