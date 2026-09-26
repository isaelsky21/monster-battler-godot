class_name MonsterController
extends RefCounted

var game_state: GameState
var rng: RandomNumberGenerator


func _init(state: GameState = null, random_number_generator: RandomNumberGenerator = null) -> void:
	game_state = state
	rng = random_number_generator


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


func get_active_monster() -> Monster:
	if game_state.is_player_turn:
		return game_state.player_monster
	else:
		return game_state.opponent_monster


func get_opposing_monster(monster: Monster) -> Monster:
	match(monster):
		game_state.player_monster:
			return game_state.opponent_monster
		game_state.opponent_monster:
			return game_state.player_monster
	return null


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
		
		var opponent: Monster = get_opposing_monster(monster)
		if opponent.hp == 0:
			monster.move_blocked = false
			return
		
		# End turn if move has been blocked by condition
		if monster.move_blocked:
			logs.append("But it can't move!")
			monster.move_blocked = false
			return
		
		# Subtract a usage when move is used
		move.usages -= 1
		
		# Save boolean that checks if a move hits (if random number is less than
		# base accuracy, then it hits 
		var hit: bool = rng.randf() < move.base_accuracy
		var crit: bool = rng.randf() < Calculations.get_critical_chance(monster)
		
		# Show message if move doesn't hit, same for critical hit
		if !hit:
			logs.append("The move missed!")
		if crit:
			logs.append("Critial hit!")
		
		# If effect hits, proceed to use effect(s)
		for effect: TargetedEffect in move.resource.use_effects:
			if effect.should_do(hit, crit):
				effect._do(monster, move, crit, logs, game_state, rng)
		
		var message_avfx: AVFXMessages = AVFXMessages.from_strings(logs as Array[String])
		var avfx_group: Array[AVFXResource] = move.resource.use_avfx.duplicate()
		avfx_group.append(message_avfx)
		AVFXManager.queue_avfx_effect_group(avfx_group, monster, game_state)
		
		var cleanup_avfx_group: Array = []
		var update_effect: AVFXFunction = AVFXFunction.new(func() -> void: Events.on_monster_updated.emit(monster))
		var target_effect: AVFXFunction = AVFXFunction.new(func() -> void: Events.on_monster_updated.emit(opponent))
		AVFXManager.queue_avfx_effect_group([update_effect, target_effect], monster, game_state)

# Function to add/subtract hp to/from monster
func adjust_monster_hp(monster: Monster, amount: int) -> void:
	# Clamp value to ensure it stays between 0 and max HP
	monster.hp = clamp(monster.hp + amount, 0, monster.max_hp)
	
	if monster.hp == 0:
		faint_monster(monster)


func faint_monster(monster: Monster) -> void:
	return


# Create condition and add to player conditions variable
func instantiate_condition_on_monster(monster: Monster, condition_resource: ConditionResource) -> void:
	# If condition has been stacked to the max, stop stacking
	if monster.conditions\
	.filter(func(condition_to_check: Condition) -> bool: return condition_to_check.resource == condition_resource)\
	.size() >= condition_resource.max_stacks:
		return
	
	var condition: Condition = Condition.new()
	condition.resource = condition_resource
	condition.duration_remaining = condition.resource.duration
	monster.conditions.append(condition)


func end_condition(monster: Monster, condition: Condition) -> void:
	monster.conditions.remove_at(monster.conditions.find(condition))


func on_turn_begun(monster: Monster) -> void:
	if monster.hp == 0:
		return
	for condition: Condition in monster.conditions:
		var logs: Array[String] = []
		AVFXManager.queue_avfx_effect_group(condition.resource.on_begin_turn_avfx, monster, game_state)
		for effect in condition.resource.on_begin_turn_effects:
			# No crits for conditions, so hardcoded as false
			effect._do(monster, condition, false, logs, game_state, rng)
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
	.format({"monster_name": monster.nickname, "level": monster.level}), [], game_state)
	
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
		.format({"monster_name": monster.nickname, "move_name": move_to_add.move_name}), [], game_state)


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
		var choice_yes: ChoiceResource = ChoiceResource.new("> Yes", func() -> void: Events.on_player_pending_learn_move.emit(labels))
		var choice_no: ChoiceResource = ChoiceResource.new\
		("> No", func() -> void: AVFXManager.queue_avfx_message\
		(did_not_learn_string, [], game_state))
		
		AVFXManager.queue_avfx_message(want_to_learn_string, [choice_yes, choice_no], game_state)
	else:
		# Handle opponent move learning
		return


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
		"new_move_name": move.move_name}), [], game_state)
	
	maybe_give_move_replace_choice(monster)
