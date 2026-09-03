class_name AVFXAnimation extends AVFXResource

@export var animation_scene: PackedScene
@export var animation_offset: Vector2 = Vector2(32.0, 32.0)


func _do(instance: AVFXInstance) -> void:
	Events.on_avfx_animation.emit(instance, animation_scene)
