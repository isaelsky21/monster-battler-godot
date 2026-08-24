class_name MonsterType

enum Type {
	NORMAL,
	PURE,
	FIRE,
	WATER,
	PLANT,
}

enum Effectiveness {
	NEUTRAL,
	WEAK,
	STRONG
}

# Damage multipliers per effectiveness
const DAMAGE_MODIFIER_BY_EFFECT: Dictionary[Effectiveness, float] = {
	Effectiveness.NEUTRAL: 1.0,
	Effectiveness.WEAK: 0.5,
	Effectiveness.STRONG: 2.0,
}

# Stores effectiveness of type against other types
const EFFECTIVENESS_BY_TYPE: Dictionary[Type, Dictionary] = {
	Type.NORMAL: {},
	Type.FIRE: {
		Type.PLANT: Effectiveness.STRONG,
		Type.WATER: Effectiveness.WEAK,
	},
	Type.WATER: {
		Type.FIRE: Effectiveness.STRONG,
		Type.PLANT: Effectiveness.WEAK,
	},
	Type.PLANT: {
		Type.WATER: Effectiveness.STRONG,
		Type.FIRE: Effectiveness.WEAK,
	},
}


static func get_type_effectiveness(source_type: Type, target_type: Type) -> Effectiveness:
	if !EFFECTIVENESS_BY_TYPE.has(source_type) or !EFFECTIVENESS_BY_TYPE[source_type].has(target_type):
		return Effectiveness.NEUTRAL
	return EFFECTIVENESS_BY_TYPE[source_type][target_type]


static func get_type_advantage_coefficient(source_type: Type, target_type: Type) -> float:
	var effectiveness: Effectiveness = get_type_effectiveness(source_type, target_type)
	return DAMAGE_MODIFIER_BY_EFFECT[effectiveness]
