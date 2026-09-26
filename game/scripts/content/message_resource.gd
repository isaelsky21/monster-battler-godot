class_name MessageResource
extends Resource

@export var text: String
@export var choices: Array[ChoiceResource]


func _init(p_text: String, p_choices: Array[ChoiceResource] = []) -> void:
	text = p_text
	choices = p_choices
