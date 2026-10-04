class_name BlockMove
extends TargetedEffect

@export_range(0.0, 1.0, 0.1) var chance_to_block_move: float = 0.5


func apply(context: EffectContext) -> void:
	if context.rng.randf() < chance_to_block_move:
		context.target.move_blocked = true
