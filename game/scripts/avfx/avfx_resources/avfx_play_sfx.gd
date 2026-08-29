class_name AVFXPlaySFX extends AVFXResource

@export var clip: AudioStream


func _do(instance: AVFXInstance) -> void:
	Events.on_avfx_sfx.emit(instance, clip)
