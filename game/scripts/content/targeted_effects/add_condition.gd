class_name AddCondition
extends TargetedEffect

@export var condition_resource: ConditionResource
@export_range(0.0, 1.0, 0.1) var chance_to_apply: float = 1.0


func apply(context: EffectContext) -> void:
	if context.rng.randf() >= chance_to_apply:
		return
	
	# Create a condition from the resource and add it to the target
	var applied: bool = context.target.add_condition(condition_resource)
	
	if applied:
		context.logs.append(
			"%s was afflicted with %s!" % [
				context.target.species_name,
				condition_resource.condition_name
			]
		)
