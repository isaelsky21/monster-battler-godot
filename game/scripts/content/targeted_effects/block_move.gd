class_name BlockMove
extends TargetedEffect

@export_range(0.0, 1.0, 0.1) var chance_to_block_move: float = 0.5


func _do(doer: Monster, source: Object, is_critical: bool, logs: Array[String], game_state: GameState, rng: RandomNumberGenerator) -> void:
	var monster_controller: MonsterController = MonsterController.new(game_state, rng)
	var target: Monster = doer if target_self else monster_controller.get_opposing_monster(doer)
	
	if rng.randf() < chance_to_block_move:
		target.move_blocked = true
