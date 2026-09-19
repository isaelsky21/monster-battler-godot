class_name AVFXFlashScreen
extends AVFXResource

@export var flash_values: Array[Vector2]


func _do(instance: AVFXInstance) -> void:
	Events.on_avfx_flash_screen.emit(instance, flash_values)
