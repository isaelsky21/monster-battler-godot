class_name ChoiceResource
extends Resource

@export var text: String
@export var function: Callable


func _init(p_text: String, p_function: Callable) -> void:
	text = p_text
	function = p_function
