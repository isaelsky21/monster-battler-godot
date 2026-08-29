class_name AVFXInstance extends Node
# Holds context like target

var target: Monster
var resource: AVFXResource


func _init(res: AVFXResource, targ: Monster) -> void:
	resource = res
	target = targ


func execute() -> void:
	resource._do(self)


func finish() -> void:
	AVFXManager.remove_effect(self)
