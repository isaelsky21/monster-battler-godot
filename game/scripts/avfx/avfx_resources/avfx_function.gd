class_name AVFXFunction
extends AVFXResource

@export var function: Callable


func _init(callable: Callable) -> void:
	function = callable


func _do(instance: AVFXInstance) -> void:
	Events.on_avfx_function.emit(instance, function)
