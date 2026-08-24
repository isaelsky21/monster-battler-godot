class_name Condition

var resource: ConditionResource
var duration_remaining: int

# Resource getter
var condition_name: String:
	get: return resource.condition_name

var short_name: String:
	get: return resource.short_name


# Used for duck-typing in TargetedEffect
func get_type() -> MonsterType.Type:
	return MonsterType.Type.NORMAL
