extends Node
class_name DamageEngine

const TYPE_FACTORS = {
	"pawn":
	{
		Enemy.EnemyPreset.BASIC_PAWN: 1.0,
		Enemy.EnemyPreset.LOOT_RUNNER: 1.0,
		Enemy.EnemyPreset.SHIELD_GUARD: 0.5,
		Enemy.EnemyPreset.CASTER: 1.0,
		Enemy.EnemyPreset.BOMBER: 1.0,
	},
	"knight":
	{
		Enemy.EnemyPreset.BASIC_PAWN: 2.0,
		Enemy.EnemyPreset.LOOT_RUNNER: 1.0,
		Enemy.EnemyPreset.SHIELD_GUARD: 2.0,
		Enemy.EnemyPreset.CASTER: 0.5,
		Enemy.EnemyPreset.BOMBER: 1.0,
	},
	"bishop":
	{
		Enemy.EnemyPreset.BASIC_PAWN: 1.0,
		Enemy.EnemyPreset.LOOT_RUNNER: 2.0,
		Enemy.EnemyPreset.SHIELD_GUARD: 0.5,
		Enemy.EnemyPreset.CASTER: 0.5,
		Enemy.EnemyPreset.BOMBER: 1.0,
	},
	"rook":
	{
		Enemy.EnemyPreset.BASIC_PAWN: 1.0,
		Enemy.EnemyPreset.LOOT_RUNNER: 1.0,
		Enemy.EnemyPreset.SHIELD_GUARD: 3.0,
		Enemy.EnemyPreset.CASTER: 1.0,
		Enemy.EnemyPreset.BOMBER: 2.0,
	},
	"queen":
	{
		Enemy.EnemyPreset.BASIC_PAWN: 2.0,
		Enemy.EnemyPreset.LOOT_RUNNER: 2.0,
		Enemy.EnemyPreset.SHIELD_GUARD: 1.0,
		Enemy.EnemyPreset.CASTER: 1.0,
		Enemy.EnemyPreset.BOMBER: 1.0,
	},
	"king":
	{
		Enemy.EnemyPreset.BASIC_PAWN: 1.0,
		Enemy.EnemyPreset.LOOT_RUNNER: 1.0,
		Enemy.EnemyPreset.SHIELD_GUARD: 1.0,
		Enemy.EnemyPreset.CASTER: 1.0,
		Enemy.EnemyPreset.BOMBER: 1.0,
	},
}


static func calculate_damage(tower_class: String, enemy: Enemy, base_damage: float) -> float:
	if enemy == null or not is_instance_valid(enemy):
		return base_damage

	var normalized_class := tower_class if tower_class != null else ""
	normalized_class = normalized_class.to_lower()

	var class_factors: Dictionary = TYPE_FACTORS.get(normalized_class, {})
	var type_factor: float = class_factors.get(enemy.preset, 1.0)
	return base_damage * type_factor
