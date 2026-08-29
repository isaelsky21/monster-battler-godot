class_name Move

var usages: int
var resource: MoveResource

# Resource getters
var move_name: String:
	get: return resource.move_name

var type: MonsterType.Type:
	get: return resource.type

var base_accuracy: float:
	get: return resource.base_accuracy

var move_priority: int:
	get: return resource.move_priority

# Can be overriden to use message specific to a move
var use_message: String:
	get: return resource.use_message

var use_avfx: Array[AVFXResource]:
	get: return resource.use_avfx


# Used for duck-typing in TargetedEffect
func get_type() -> MonsterType.Type:
	return type
