class_name DoDamage
extends TargetedEffect

@export var base_damage: int
# For conditions that persist for multiple turns
@export var ignore_stats: bool
@export var damage_log_string: String = "{doer_name} hits {target_name} for {amt} damage"
@export var critical_hit_damage_coefficient: float = 1.5


#TODO: Make target a parameter for selecting a target in double battles, and others
func _do(doer: Monster, source: Object, is_critical: bool, logs: Array[String], game_state: GameState, rng: RandomNumberGenerator) -> void:
	var monster_controller: MonsterController = MonsterController.new(game_state, rng)
	var target: Monster = doer if target_self else monster_controller.get_opposing_monster(doer)
	var type: MonsterType.Type = source.get_type() if source.has_method("get_type") else MonsterType.Type.NORMAL
	
	# Coefficients
	var type_advantage_coefficient: float = MonsterType.get_type_advantage_coefficient(type, target.type)
	# max ensures attack is never divided by zero and cause an error
	var stat_diff_coefficient: int = 1 if ignore_stats else int(doer.attack / max(1, target.defense))
	var crit_coefficient: float = critical_hit_damage_coefficient if is_critical else 1.0
	
	var amount: int = int(base_damage * type_advantage_coefficient * stat_diff_coefficient * crit_coefficient)
	
	monster_controller.adjust_monster_hp(target, -amount)
	
	var effectiveness: MonsterType.Effectiveness = MonsterType.get_type_effectiveness(type, target.type)
	
	logs.append(damage_log_string\
		.format({"doer_name": doer.species_name, "target_name": target.species_name,\
			"amt": amount}))
	
	match(effectiveness):
		MonsterType.Effectiveness.WEAK:
			logs.append("It was hardly effective...")
		MonsterType.Effectiveness.STRONG:
			logs.append("It was highly effective...")
