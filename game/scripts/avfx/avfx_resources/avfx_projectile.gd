class_name AVFXProjectile extends AVFXResource

@export var sprite: Texture2D
@export var sprite_offset: Vector2 = Vector2(32.0, 32.0)
@export var duration: float = 0.5


func _do(instance: AVFXInstance) -> void:
	Events.on_avfx_projectile.emit(instance, sprite)
