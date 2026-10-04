class_name AVFXInstance
extends Node
# Holds context like target

var resource: AVFXResource
var user: Monster
var target: Monster

var target_self: bool:
	get: return resource.target_self
var delay: float:
	get: return resource.delay


func _init(
	p_resource: AVFXResource,
	p_user: Monster,
	p_target: Monster
) -> void:
	resource = p_resource
	user = p_user
	target = p_target


func execute() -> void:
	resource._do(self)


func finish() -> void:
	AVFXManager.remove_effect(self)
