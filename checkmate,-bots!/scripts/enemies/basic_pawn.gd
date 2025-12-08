extends "res://scripts/core/enemy.gd"
class_name WorkerBot


func _ready():
	enemy_name = "Worker Bot"
	description = "A basic worker robot. Nothing special, but gets the job done."

	move_speed = 100.0
	waypoint_threshold = 5.0

	max_health = 10.0
	damage_to_base = 1
	currency_reward = 1
	attack_interval = 1.0

	enemy_class = "pawn"
	color = Color("blue")
	preset = EnemyPreset.BASIC_PAWN

	super._ready()
	print("Worker Bot spawned")
