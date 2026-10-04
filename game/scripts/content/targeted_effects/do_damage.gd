class_name DoDamage
extends TargetedEffect

@export var base_damage: int
# For conditions that persist for multiple turns
@export var ignore_stats: bool
@export var damage_log_string: String = "{user_name} hits {target_name} for {amount} damage"
@export var critical_hit_damage_coefficient: float = 1.5


#TODO: Make target a parameter for selecting a target in double battles, and others
func apply(context: EffectContext) -> void:
	var type_advantage: float = MonsterType.get_type_advantage_coefficient(
		context.source_type,
		context.target.type
	)
	
	var stat_coefficient: float = 1.0
	
	if not ignore_stats:
		stat_coefficient = float(context.user.attack) / maxf(
			1.0,
			float(context.target.defense)
		)
	
	var crit_coefficient: float = \
		critical_hit_damage_coefficient \
		if context.is_critical \
		else 1.0
	
	var amount: int = maxi(
		1,
		int(
			base_damage
			* type_advantage
			* stat_coefficient
			* crit_coefficient
		)
	)
	
	context.target.adjust_hp(-amount)
	
	var effectiveness: MonsterType.Effectiveness = MonsterType.get_type_effectiveness(
		context.source_type,
		context.target.type
	)
	
	context.logs.append(damage_log_string\
		.format({"user_name": context.user.species_name, "target_name": context.target.species_name,\
			"amount": amount}))
	
	match effectiveness:
		MonsterType.Effectiveness.WEAK:
			context.logs.append("It was hardly effective...")
		MonsterType.Effectiveness.STRONG:
			context.logs.append("It was highly effective...")
