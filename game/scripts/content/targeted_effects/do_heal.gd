class_name DoHeal
extends TargetedEffect

@export var base_heal: int


#TODO: Make target a parameter for selecting a target in double battles, and others
func apply(context: EffectContext) -> void:
	context.target.adjust_hp(base_heal)
	
	context.logs.append(
		"{target_name} recovers {amt} HP.".format({
			"target_name": context.target.species_name,
			"amt": base_heal
		})
	)
