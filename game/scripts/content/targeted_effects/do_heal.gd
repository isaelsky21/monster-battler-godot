class_name DoHeal
extends TargetedEffect

@export var base_heal: int


#TODO: Make target a parameter for selecting a target in double battles, and others
func apply(context: EffectContext) -> void:
	var previous_hp: int = context.target.hp
	
	context.target.adjust_hp(base_heal)
	
	var amount_healed: int = context.target.hp - previous_hp
	
	context.logs.append(
		"{target_name} recovers {amount} HP.".format({
			"target_name": context.target.species_name,
			"amount": amount_healed
		})
	)
