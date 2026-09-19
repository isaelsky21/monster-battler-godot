class_name AVFXMessages
extends AVFXResource

@export var messages: Array[String]


func _init(p_messages: Array[String]) -> void:
	messages = p_messages


func _do(instance: AVFXInstance) -> void:
	Events.on_avfx_messages.emit(instance, messages)
	for message in messages:
		Events.request_log.emit(message)
