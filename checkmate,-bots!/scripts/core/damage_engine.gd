extends Node
class_name DamageEngine

const TYPE_FACTORS = {
	"pawn": {
		Enemy.EnemyPreset.BASIC_PAWN: 1.0,
		Enemy.EnemyPreset.LOOT_RUNNER: 1.0,
		Enemy.EnemyPreset.SHIELD_GUARD: 1.0,
		Enemy.EnemyPreset.CASTER: 1.0,
		Enemy.EnemyPreset.BOMBER: 1.0,
	},
	"knight": {
		Enemy.EnemyPreset.BASIC_PAWN: 1.0,
		Enemy.EnemyPreset.LOOT_RUNNER: 1.0,
		Enemy.EnemyPreset.SHIELD_GUARD: 1.0,
		Enemy.EnemyPreset.CASTER: 1.0,
		Enemy.EnemyPreset.BOMBER: 1.0,
	},
	"bishop": {
		Enemy.EnemyPreset.BASIC_PAWN: 1.0,
		Enemy.EnemyPreset.LOOT_RUNNER: 1.0,
		Enemy.EnemyPreset.SHIELD_GUARD: 1.0,
		Enemy.EnemyPreset.CASTER: 1.0,
		Enemy.EnemyPreset.BOMBER: 1.0,
	},
	"rook": {
		Enemy.EnemyPreset.BASIC_PAWN: 1.0,
		Enemy.EnemyPreset.LOOT_RUNNER: 1.0,
		Enemy.EnemyPreset.SHIELD_GUARD: 1.0,
		Enemy.EnemyPreset.CASTER: 1.0,
		Enemy.EnemyPreset.BOMBER: 1.0,
	},
	"queen": {
		Enemy.EnemyPreset.BASIC_PAWN: 1.0,
		Enemy.EnemyPreset.LOOT_RUNNER: 1.0,
		Enemy.EnemyPreset.SHIELD_GUARD: 1.0,
		Enemy.EnemyPreset.CASTER: 1.0,
		Enemy.EnemyPreset.BOMBER: 1.0,
	},
	"king": {
		Enemy.EnemyPreset.BASIC_PAWN: 1.0,
		Enemy.EnemyPreset.LOOT_RUNNER: 1.0,
		Enemy.EnemyPreset.SHIELD_GUARD: 1.0,
		Enemy.EnemyPreset.CASTER: 1.0,
		Enemy.EnemyPreset.BOMBER: 1.0,
	},
}

static func calculate_damage(tower_class: String, enemy: Enemy, base_damage: float) -> float:
	var type_factor = TYPE_FACTORS[tower_class][enemy.preset]
	return base_damage * type_factor
