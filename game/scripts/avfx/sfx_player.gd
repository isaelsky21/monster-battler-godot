extends AudioStreamPlayer2D


func _ready() -> void:
	Events.on_avfx_sfx.connect(play_sfx)


func play_sfx(instance: AVFXInstance, clip: AudioStream) -> void:
	# Add a bit of randomness to sound pitch
	pitch_scale = randf_range(0.9, 1.1)
	stream = clip
	play()
	finished.connect(instance.finish)
