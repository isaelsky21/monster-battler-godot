class_name AddCondition extends TargetedEffect

@export var condition_resource: ConditionResource
@export_range(0.0, 1.0, 0.1) var chance_to_apply: float = 1.0


func _do(doer: Monster, _source: Object, _is_critical: bool, game_state: GameState, rng: RandomNumberGenerator) -> void:
	var monster_controller: MonsterController = MonsterController.new(game_state, rng)
	var target: Monster = doer if target_self else monster_controller.get_opposing_monster(doer)
	
	if rng.randf() < chance_to_apply:
		# Create a condition from the resource and add it to the target
		monster_controller.instantiate_condition_on_monster(target, condition_resource)
