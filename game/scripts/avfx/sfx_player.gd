extends AudioStreamPlayer2D


func _ready() -> void:
	Events.on_avfx_sfx.connect(play_sfx)


func play_sfx(instance: AVFXInstance, clip: AudioStream) -> void:
	if instance.delay == 0:
		do_play_sfx(instance, clip)
	else:
		await get_tree().create_timer(instance.delay)\
			.timeout.connect(func() -> void: do_play_sfx(instance, clip))


func do_play_sfx(instance: AVFXInstance, clip: AudioStream) -> void:
	# Add a bit of randomness to sound pitch
	pitch_scale = randf_range(0.9, 1.1)
	stream = clip
	finished.connect(instance.finish)
	play()
