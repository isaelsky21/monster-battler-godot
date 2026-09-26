class_name AVFXMessages
extends AVFXResource

@export var messages: Array[MessageResource]


func _init(p_messages: Array[MessageResource]) -> void:
	messages = p_messages


func _do(instance: AVFXInstance) -> void:
	Events.on_avfx_messages.emit(instance)
	for message: MessageResource in messages:
		Events.request_log.emit(message.text)


static func from_strings(strings: Array[String]) -> AVFXMessages:
	var avfx_messages_resource: AVFXMessages = AVFXMessages.new([])
	for text: String in strings:
		var message_resource: MessageResource = MessageResource.new(text)
		avfx_messages_resource.messages.append(message_resource)
	return avfx_messages_resource
