@abstract
class_name AVFXResource extends Resource

@export var target_self: bool
@export var delay: float


@abstract
func _do(instance: AVFXInstance) -> void


func generate(user: Monster, target: Monster) -> AVFXInstance:
	return AVFXInstance.new(self, user, target)
