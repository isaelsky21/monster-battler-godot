class_name AVFXInstance extends Node
# Holds context like target

var user: Monster
var target: Monster
var resource: AVFXResource

var target_self: bool:
	get: return resource.target_self
var sprite_offset: Vector2:
	get: return resource.sprite_offset
var animation_offset: Vector2:
	get: return resource.animation_offset
var duration: float:
	get: return resource.duration
var delay: float:
	get: return resource.delay


func _init(res: AVFXResource, usr: Monster, targ: Monster) -> void:
	resource = res
	user = usr
	target = targ


func execute() -> void:
	resource._do(self)


func finish() -> void:
	AVFXManager.remove_effect(self)
