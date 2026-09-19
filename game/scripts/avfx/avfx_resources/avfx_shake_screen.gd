class_name AVFXShakeScreen
extends AVFXResource

@export var screen_offsets_and_timings: Array[Vector3]


func _do(instance: AVFXInstance) -> void:
	Events.on_avfx_shake_screen.emit(instance, screen_offsets_and_timings)
