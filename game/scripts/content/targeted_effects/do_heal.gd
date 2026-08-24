class_name DoHeal extends TargetedEffect

@export var base_heal: int


#TODO: Make target a parameter for selecting a target in double battles, and others
func _do(doer: Monster, _source: Object, is_critical: bool, game_state: GameState, rng: RandomNumberGenerator) -> void:
	var monster_controller: MonsterController = MonsterController.new(game_state, rng)
	var target: Monster = doer if target_self else monster_controller.get_opposing_monster(doer)
	
	var amount: int = base_heal
	
	monster_controller.adjust_monster_hp(target, amount)
	
	Events.request_log.emit("{target_name} recovers {amt} HP."\
		.format({ "target_name": target.species_name, "amt": amount}))
