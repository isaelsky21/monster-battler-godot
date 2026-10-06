class_name MonsterController
extends RefCounted

var game_state: GameState
var rng: RandomNumberGenerator


func _init(
	p_game_state: GameState,
	p_rng: RandomNumberGenerator
) -> void:
	game_state = p_game_state
	rng = p_rng


func create_monster(species: SpeciesResource, nickname: String = "") -> Monster:
	var monster: Monster = Monster.new()
	monster.species = species
	monster.hp = species.base_max_hp
	monster.nickname = nickname
	monster.hp_growth = rng.randf_range(0.4, 1.2)
	monster.attack_growth = rng.randf_range(0.4, 1.2)
	monster.defense_growth = rng.randf_range(0.4, 1.2)
	monster.special_attack_growth = rng.randf_range(0.4, 1.2)
	monster.special_defense_growth = rng.randf_range(0.4, 1.2)
	monster.speed_growth = rng.randf_range(0.4, 1.2)
	
	for move_resource: MoveResource in species.starting_moves:
		if move_resource == null:
			continue
		var move: Move = Move.new()
		move.resource = move_resource
		move.usages = move_resource.max_usages
		monster.moves.append(move)
	
	monster.fallback_move = Move.new()
	monster.fallback_move.resource = preload("res://content/moves/struggle.tres")
	monster.fallback_move.usages = 999
	
	return monster


func get_monster_move_at_index(monster: Monster, index: int) -> Move:
	if index == -1:
		return monster.fallback_move
	return monster.moves[index]


func use_monster_move(monster: Monster, move: Move) -> void:
	# If no move usages or hp left, don't use move
	if move.usages <= 0 or monster.hp == 0:
		return
	
	var logs: Array[String] = []
	
	# Check if there are any move usages remaining
	if move.usages > 0:
		# Show log message showing monster and move
		var use_message: String = move.use_message.format({"user_name": monster.species_name, "move_name": move.move_name})
		logs.append(use_message)
		
		var opponent: Monster = game_state.get_opposing_monster(monster)
		if opponent.hp == 0:
			monster.move_blocked = false
			return
		
		# End turn if move has been blocked by condition
		if monster.move_blocked:
			logs.append("But it can't move!")
			monster.move_blocked = false
			
			var move_blocked_message_avfx: AVFXMessages = AVFXMessages.from_strings(logs)
	
			AVFXManager.queue_avfx_effect_group(
				[move_blocked_message_avfx],
				null,
				null
			)
			
			return
		
		# Subtract a usage when move is used
		move.usages -= 1
		
		# Save boolean that checks if a move hits (if random number is less than
		# base accuracy, then it hits 
		var hit: bool = rng.randf() < move.base_accuracy
		var crit: bool = (
			hit
			and rng.randf() < Calculations.get_critical_chance(monster)
		)
		
		
		# Show message if move doesn't hit, same for critical hit
		if !hit:
			logs.append("The move missed!")
		if crit:
			logs.append("Critical hit!")
		
		# If effect hits, proceed to use effect(s)
		for effect: TargetedEffect in move.resource.use_effects:
			if effect.should_do(hit, crit):
				var context: EffectContext = create_effect_context(
					monster,
					effect,
					move.type,
					crit,
					logs
				)
				
				effect.apply(context)
		
		var message_avfx: AVFXMessages = AVFXMessages.from_strings(logs)
		var avfx_group: Array[AVFXResource] = move.resource.use_avfx.duplicate()
		avfx_group.append(message_avfx)
		AVFXManager.queue_avfx_effect_group(avfx_group, monster, opponent)
		
		var update_effect: AVFXFunction = AVFXFunction.new(func() -> void: Events.on_monster_updated.emit(monster))
		var target_effect: AVFXFunction = AVFXFunction.new(func() -> void: Events.on_monster_updated.emit(opponent))
		AVFXManager.queue_avfx_effect_group([update_effect, target_effect], null, null)


func end_condition(
	monster: Monster,
	condition: Condition
) -> void:
	var index: int = monster.conditions.find(condition)
	
	if index == -1:
		return
	
	monster.conditions.remove_at(index)


func on_turn_begun(monster: Monster) -> void:
	if monster.hp == 0:
		return
	
	var opponent: Monster = game_state.get_opposing_monster(monster)
	
	for condition: Condition in monster.conditions.duplicate():
		var logs: Array[String] = []
		
		for effect: TargetedEffect in condition.resource.on_begin_turn_effects:
			# No crits for conditions, so hardcoded as false
			var context: EffectContext = create_effect_context(
				monster,
				effect,
				condition.type,
				false,
				logs
			)
			
			effect.apply(context)
		
		var avfx_group: Array[AVFXResource] = \
			condition.resource.on_begin_turn_avfx.duplicate()
		
		if not logs.is_empty():
			var message_avfx: AVFXMessages = AVFXMessages.from_strings(logs)
			avfx_group.append(message_avfx)
		
		AVFXManager.queue_avfx_effect_group(
			avfx_group,
			monster,
			opponent
		)
		
		condition.duration_remaining -= 1
		
		if condition.duration_remaining <= 0:
			end_condition(monster, condition)


func add_experience_to_monster(monster: Monster, experience: int) -> void:
	monster.experience += experience
	
	for index in range(monster.level, monster.max_level):
		var required_experience: int = Calculations.experience_for_level(monster.level)
		if monster.experience >= required_experience:
			monster.experience -= required_experience
			level_up_monster(monster)
		else:
			break
	
	maybe_give_move_replace_choice(monster)


func level_up_monster(monster: Monster) -> void:
	monster.level += 1
	AVFXManager.queue_avfx_message("{monster_name} leveled up to level {level}"\
	.format({"monster_name": monster.nickname, "level": monster.level}), [])
	
	# Search moves learned at current monster level and add to list
	var moves_to_learn: Array[IntMoveResource] = monster.species.moves_learned_by_level.filter(func(int_move: IntMoveResource) -> bool: return int_move.level == monster.level)
	for move_to_learn: IntMoveResource in moves_to_learn:
		monster.pending_moves.append(move_to_learn.move)
	
	# Save amount of empty move spaces left
	var available_slots: int = monster.max_moves - monster.moves.size()
	var moves_to_transfer: int = min(available_slots, monster.pending_moves.size())
	
	# Iterate through list and create and add the moves to monster move list
	for _i in range(moves_to_transfer):
		var move_to_add: MoveResource = monster.pending_moves.pop_front()
		var move: Move = Move.new()
		move.resource = move_to_add
		move.usages = move.resource.max_usages
		monster.moves.append(move)
		
		AVFXManager.queue_avfx_message("{monster_name} learned {move_name}"\
		.format({"monster_name": monster.nickname, "move_name": move_to_add.move_name}), [])


# Ask player if they want to replace move with newly learned one
func maybe_give_move_replace_choice(monster: Monster) -> void:
	if monster.pending_moves.size() == 0:
		return
	
	monster.pending_move = monster.pending_moves.pop_front()
	
	if monster == game_state.player_monster:
		var labels: Array[StringEnabled] = []
		for move: Move in monster.moves:
			labels.append(StringEnabled.new(move.move_name, true))
		
		var want_to_learn_string: String = "{monster_name} wants to learn {move_name}.\
			Replace a move?".format({"monster_name": monster.nickname,\
				"move_name": monster.pending_move.move_name})
		var did_not_learn_string: String = "{monster_name} did not learn {move_name}."\
			.format({"monster_name": monster.nickname, "move_name": monster.pending_move.move_name})
		var choice_yes: ChoiceResource = ChoiceResource.new(
			"> Yes",
			func() -> void:
				Events.on_player_pending_learn_move.emit(labels))
		var choice_no: ChoiceResource = ChoiceResource.new(
			"> No",
			func() -> void:
				decline_pending_move(
					monster,
					did_not_learn_string
				)
		)
		
		AVFXManager.queue_avfx_message(want_to_learn_string, [choice_yes, choice_no])
	else:
		# Handle opponent move learning
		return


func decline_pending_move(
	monster: Monster,
	message: String
) -> void:
	AVFXManager.queue_avfx_message(message, [])
	
	monster.pending_move = null
	
	maybe_give_move_replace_choice(monster)


func set_monster_move_at_index_to_pending_move(monster: Monster, index: int) -> void:
	var previous_move: Move = monster.moves[index]
	var move: Move = Move.new()
	move.resource = monster.pending_move
	move.usages = move.resource.max_usages
	monster.moves[index] = move
	monster.pending_move = null
	
	Events.on_player_move_replace_completed.emit()
	
	AVFXManager.queue_avfx_message("{monster_name} forgot {old_move_name}\
		and learned {new_move_name}".format({"monster_name": monster.nickname,\
		"old_move_name": previous_move.move_name,\
		"new_move_name": move.move_name}), [])
	
	maybe_give_move_replace_choice(monster)


func create_effect_context(
	user: Monster,
	effect: TargetedEffect,
	source_type: MonsterType.Type,
	is_critical: bool,
	logs: Array[String]
) -> EffectContext:
	var target: Monster
	
	if effect.target_self:
		target = user
	else:
		target = game_state.get_opposing_monster(user)
	
	return EffectContext.new(
		user,
		target,
		source_type,
		is_critical,
		logs,
		rng
	)
