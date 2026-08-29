@abstract
class_name TargetedEffect extends Resource

enum OutcomeFilter {
	HIT,
	MISS,
	BOTH,
	CRIT,
}

@export var outcome_filter: OutcomeFilter
@export var target_self: bool


#TODO: Make target a parameter for selecting a target in double or more battles
#TODO: Remove duck typing from source, find alternative
@abstract
func _do(_doer: Monster, _source: Object, _is_critical: bool, _game_state: GameState, _rng: RandomNumberGenerator) -> void


func should_do(is_hit: bool, is_critical: bool) -> bool:
	return outcome_filter == OutcomeFilter.BOTH\
		or (is_hit and outcome_filter == OutcomeFilter.HIT)\
		or (!is_hit and outcome_filter == OutcomeFilter.MISS)\
		or (is_critical and outcome_filter == OutcomeFilter.CRIT)
