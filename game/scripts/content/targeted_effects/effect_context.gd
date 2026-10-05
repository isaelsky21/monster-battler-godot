class_name EffectContext
extends RefCounted

var user: Monster
var target: Monster
var source_type: MonsterType.Type
var is_critical: bool
var logs: Array[String] = []
var rng: RandomNumberGenerator


func _init(
	p_user: Monster,
	p_target: Monster,
	p_source_type: MonsterType.Type,
	p_is_critical: bool,
	p_logs: Array[String],
	p_rng: RandomNumberGenerator
) -> void:
	user = p_user
	target = p_target
	source_type = p_source_type
	is_critical = p_is_critical
	logs = p_logs
	rng = p_rng
