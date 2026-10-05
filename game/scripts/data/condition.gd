class_name Condition

var resource: ConditionResource
var duration_remaining: int

# Resource getter
var type: MonsterType.Type:
	get: return resource.type
var condition_name: String:
	get: return resource.condition_name
var short_name: String:
	get: return resource.short_name
