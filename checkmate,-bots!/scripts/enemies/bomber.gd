extends "res://scripts/core/enemy.gd"
class_name BombDrone

@export var enrage_path_ratio: float = 0.5  # When % of path reached, it speeds up
@export var speed_multiplier: float = 1.8  # How much faster after enraging

var _enraged: bool = false


func _ready():
	enemy_name = "Bomb Drone"
	description = "Explosive drone. Starts slow but speeds up halfway. High damage on impact!"

	move_speed = 70.0  # Starts slow
	waypoint_threshold = 5.0

	max_health = 120.0
	damage_to_base = 5
	currency_reward = 25
	attack_interval = 0.0

	enemy_class = "bomber"
	color = Color("orange")
	preset = EnemyPreset.BOMBER

	_enraged = false

	super._ready()
	print("Bomb Drone spawned")


func _physics_process(delta: float):
	if not is_alive:
		return

	if not _enraged and path_points.size() > 0:
		var trigger_index: int = int(path_points.size() * enrage_path_ratio)
		if current_waypoint_index >= trigger_index:
			_enrage()

	super._physics_process(delta)


func _enrage():
	_enraged = true
	move_speed *= speed_multiplier
	color = Color("orangered")  # Change to red-orange when enraged (mainly so player knonws)
	queue_redraw()
	print("Bomb Drone enraged! Speed increased!")


func _reach_end_of_path():
	is_active = false
	# Suicide attack - explode and deal damage
	enemy_reached_end.emit(self)
	queue_free()
