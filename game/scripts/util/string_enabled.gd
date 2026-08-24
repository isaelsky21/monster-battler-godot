class_name StringEnabled

# A simple data class used for passing a string with a boolean

var string: String
var enabled: bool

func _init(s: String, en: bool) -> void:
	string = s
	enabled = en
