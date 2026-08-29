@abstract
class_name AVFXResource extends Resource

@export var target_self: bool


@abstract
func _do(instance: AVFXInstance) -> void


func generate(target: Monster) -> AVFXInstance:
	return AVFXInstance.new(self, target)
