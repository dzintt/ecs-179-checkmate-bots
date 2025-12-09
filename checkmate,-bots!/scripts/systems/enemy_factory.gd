extends Node
class_name EnemyFactory


# Data holders
class EnemySpec:
	var id: String
	var scene: PackedScene
	var move_speed: float
	var max_health: float
	var damage_to_base: int
	var delay_range: Vector2

	func _init(
		_id: String,
		_scene: PackedScene,
		_move_speed: float,
		_max_health: float,
		_damage_to_base: int,
		_delay_range: Vector2 = Vector2(0.7, 1.1)
	):
		id = _id
		scene = _scene
		move_speed = _move_speed
		max_health = _max_health
		damage_to_base = _damage_to_base
		delay_range = _delay_range


class WaveSpec:
	var wave_number: int
	var target_score: float
	var min_enemies: int
	var max_enemies: int
	var allowed_ids: Array[String]
	var directions: Array[String]
	var variance_pct: float
	var bias_heavy_vs_light: float
	var delay_range: Vector2

	func _init(
		_wave_number: int,
		_target_score: float,
		_min_enemies: int,
		_max_enemies: int,
		_allowed_ids: Array[String],
		_directions: Array[String],
		_delay_range: Vector2,
		_variance_pct: float = 0.12,
		_bias_heavy_vs_light: float = 0.0
	):
		wave_number = _wave_number
		target_score = _target_score
		min_enemies = _min_enemies
		max_enemies = _max_enemies
		allowed_ids = _allowed_ids
		directions = _directions
		delay_range = _delay_range
		variance_pct = _variance_pct
		bias_heavy_vs_light = clamp(_bias_heavy_vs_light, -1.0, 1.0)


const DEFAULT_DIRECTIONS: Array[String] = [
	"north",
	"north2",
	"east",
	"east2",
	"south",
	"south2",
	"west",
	"west2",
]

const ENEMY_SCENES := {
	"pawn": preload("res://scenes/enemies/basic_pawn.tscn"),
	"runner": preload("res://scenes/enemies/loot_runner.tscn"),
	"shield": preload("res://scenes/enemies/shielder.tscn"),
	"bomber": preload("res://scenes/enemies/bomber.tscn"),
	"caster": preload("res://scenes/enemies/caster.tscn"),
}

const FIXED_THREAT := {
	"pawn": 1.0,
	"runner": 2.0,
	"caster": 3.0,
	"bomber": 4.0,
	"shield": 5.0,
}

var enemy_specs: Dictionary = {}
var rng := RandomNumberGenerator.new()


func _init():
	rng.randomize()


func register_default_specs():
	enemy_specs.clear()
	enemy_specs["pawn"] = EnemySpec.new(
		"pawn", ENEMY_SCENES["pawn"], 100.0, 10, 1, Vector2(0.9, 1.3)
	)
	enemy_specs["runner"] = EnemySpec.new(
		"runner", ENEMY_SCENES["runner"], 220.0, 30, 5, Vector2(0.8, 1.2)
	)
	enemy_specs["shield"] = EnemySpec.new(
		"shield", ENEMY_SCENES["shield"], 60.0, 100, 10, Vector2(0.8, 1.15)
	)
	enemy_specs["bomber"] = EnemySpec.new(
		"bomber", ENEMY_SCENES["bomber"], 70.0, 50, 10, Vector2(0.9, 1.3)
	)
	enemy_specs["caster"] = EnemySpec.new(
		"caster", ENEMY_SCENES["caster"], 80.0, 50, 5, Vector2(0.7, 1.0)
	)


func get_scene(enemy_id: String) -> PackedScene:
	if enemy_specs.has(enemy_id):
		return enemy_specs[enemy_id].scene
	return ENEMY_SCENES.get(enemy_id, ENEMY_SCENES.get("pawn"))


func get_threat(enemy_id: String) -> float:
	if FIXED_THREAT.has(enemy_id):
		return FIXED_THREAT[enemy_id]
	return 1.0


func _valid_ids(source: Array) -> Array[String]:
	var seen := {}
	var filtered: Array[String] = []
	for id in source:
		if typeof(id) != TYPE_STRING:
			continue
		if not enemy_specs.has(id) or seen.has(id):
			continue
		seen[id] = true
		filtered.append(id)
	return filtered


func _build_costs(ids: Array[String]) -> Dictionary:
	var costs := {}
	for id in ids:
		if not enemy_specs.has(id):
			continue
		costs[id] = int(round(get_threat(id)))
	return costs


func generate_wave(spec: WaveSpec) -> Dictionary:
	var ids: Array[String] = _valid_ids(spec.allowed_ids)
	if ids.is_empty():
		var all_ids: Array = []
		all_ids.assign(enemy_specs.keys())
		ids = _valid_ids(all_ids)

	var budget: int = int(round(spec.target_score))
	var costs := _build_costs(ids)
	var composition: Array[String] = _random_exact_composition(
		budget, ids, spec.min_enemies, spec.max_enemies, costs
	)
	if composition.is_empty():
		composition = _solve_exact_composition(
			budget, ids, spec.min_enemies, spec.max_enemies, costs
		)

	if composition.is_empty():
		return {"wave_number": spec.wave_number, "spawn_data": []}

	var spawn_data: Array = []
	for enemy_id in composition:
		_append_spawn(spawn_data, enemy_id, spec)

	return {
		"wave_number": spec.wave_number,
		"spawn_data": spawn_data,
		"target_score": spec.target_score,
		"estimated_spent": float(budget),
	}


func _append_spawn(spawn_data: Array, enemy_id: String, spec: WaveSpec):
	var direction := _pick_direction(spec, spawn_data.size())
	var delay := _pick_delay(enemy_id, spec)

	var last_index := spawn_data.size() - 1
	if last_index >= 0:
		var last: Dictionary = spawn_data[last_index]
		var same_type: bool = last.get("type", "") == enemy_id
		var same_direction: bool = last.get("direction", "") == direction
		var rounded_last_delay: float = _round_delay(last.get("delay", delay))
		var rounded_delay: float = _round_delay(delay)
		var same_delay: bool = abs(rounded_last_delay - rounded_delay) <= 0.01
		if same_type and same_direction and same_delay:
			last["count"] = int(last.get("count", 1)) + 1
			last["delay"] = rounded_delay
			spawn_data[last_index] = last
			return

	(
		spawn_data
		. append(
			{
				"direction": direction,
				"count": 1,
				"delay": _round_delay(delay),
				"type": enemy_id,
			}
		)
	)


func _round_delay(value: float) -> float:
	return roundf(value * 100.0) / 100.0


func _pick_direction(spec: WaveSpec, spawn_index: int) -> String:
	var dirs := spec.directions
	if dirs.is_empty():
		dirs = DEFAULT_DIRECTIONS
	var idx: int = spawn_index % dirs.size()
	return dirs[idx]


func _pick_delay(enemy_id: String, spec: WaveSpec) -> float:
	var wave_min: float = spec.delay_range.x
	var wave_max: float = spec.delay_range.y
	var clamped_wave_min: float = min(wave_min, wave_max)
	var clamped_wave_max: float = max(wave_min, wave_max)

	var enemy_delay: Vector2 = spec.delay_range
	if enemy_specs.has(enemy_id):
		enemy_delay = enemy_specs[enemy_id].delay_range

	var min_delay: float = max(0.2, min(enemy_delay.x, clamped_wave_min))
	var max_delay: float = max(enemy_delay.y, clamped_wave_max)
	return rng.randf_range(min_delay, max_delay)


func _solve_exact_composition(
	budget: int, ids: Array[String], min_count: int, max_count: int, costs: Dictionary = {}
) -> Array[String]:
	# Build an exact-cost loadout that hits the budget within the enemy count bounds.
	if costs.is_empty():
		costs = _build_costs(ids)
	var cheapest_id := ""
	var cheapest_cost: int = 2147483647
	for id in costs.keys():
		var cost: int = int(costs[id])
		if cost < cheapest_cost:
			cheapest_cost = cost
			cheapest_id = id

	if costs.is_empty():
		return []

	var cost_ids: Array[String] = []
	for key in costs.keys():
		if typeof(key) == TYPE_STRING:
			cost_ids.append(key)
	var dp: Array = []
	for i in range(max_count + 1):
		dp.append({})
	dp[0][0] = [] as Array[String]

	for count in range(max_count):
		for score in dp[count].keys():
			var current: Array[String] = dp[count][score]
			for id in cost_ids:
				var cost: int = costs[id]
				var new_score: int = score + cost
				var new_count: int = count + 1
				if new_count > max_count or new_score > budget:
					continue

				if not dp[new_count].has(new_score):
					var next: Array[String] = current.duplicate()
					next.append(id)
					dp[new_count][new_score] = next

	for count in range(min_count, max_count + 1):
		if dp[count].has(budget):
			return dp[count][budget]

	# Fallback: take the best-under-budget combo and pad with the cheapest unit if it fits.
	var best_score := -1
	var best_combo: Array[String] = []
	for count in range(min_count, max_count + 1):
		for score in dp[count].keys():
			if score > budget:
				continue
			if score > best_score:
				best_score = score
				best_combo = dp[count][score]

	if best_score >= 0 and cheapest_id != "":
		var remaining := budget - best_score
		var padded: Array[String] = best_combo.duplicate()
		while remaining >= cheapest_cost and padded.size() < max_count:
			padded.append(cheapest_id)
			remaining -= cheapest_cost
		if remaining == 0 and padded.size() >= min_count and padded.size() <= max_count:
			return padded

	return []


func _random_exact_composition(
	budget: int, ids: Array[String], min_count: int, max_count: int, costs: Dictionary
) -> Array[String]:
	if costs.is_empty():
		return []

	var shuffled := ids.duplicate()
	shuffled.shuffle()

	var solutions: Array = []
	var stack: Array = [
		{
			"remaining": budget,
			"combo": [] as Array[String],
		},
	]

	while not stack.is_empty() and solutions.size() < 200:
		var state: Dictionary = stack.pop_back()
		var remaining: int = state["remaining"]
		var current: Array[String] = state["combo"]

		if remaining == 0:
			if current.size() >= min_count and current.size() <= max_count:
				solutions.append(current)
			continue

		if current.size() >= max_count or remaining < 0:
			continue

		for id in shuffled:
			if not costs.has(id):
				continue
			var cost: int = int(costs[id])
			if cost > remaining:
				continue
			var next_combo: Array[String] = current.duplicate()
			next_combo.append(id)
			(
				stack
				. append(
					{
						"remaining": remaining - cost,
						"combo": next_combo,
					}
				)
			)

	if solutions.is_empty():
		return []

	var pick: int = rng.randi_range(0, solutions.size() - 1)
	var chosen: Array[String] = []
	for id in solutions[pick]:
		if typeof(id) == TYPE_STRING:
			chosen.append(id)
	return chosen
