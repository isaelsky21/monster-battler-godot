@abstract
class_name TargetedEffect
extends Resource

enum OutcomeFilter {
	HIT,
	MISS,
	BOTH,
	CRIT,
}

@export var target_self: bool
@export var outcome_filter: OutcomeFilter


#TODO: Make target a parameter for selecting a target in double or more battles
@abstract
func apply(context: EffectContext) -> void


func should_do(is_hit: bool, is_critical: bool) -> bool:
	match outcome_filter:
		OutcomeFilter.BOTH:
			return true
		OutcomeFilter.HIT:
			return is_hit
		OutcomeFilter.MISS:
			return not is_hit
		OutcomeFilter.CRIT:
			return is_critical
	
	return false
