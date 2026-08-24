class_name MonsterController extends RefCounted

var game_state: GameState
var rng: RandomNumberGenerator


func _init(state: GameState, random_number_generator: RandomNumberGenerator) -> void:
	game_state = state
	rng = random_number_generator


func create_monster(species: SpeciesResource, nickname: String = "") -> Monster:
	var monster: Monster = Monster.new()
	monster.species = species
	monster.hp = species.base_max_hp
	monster.nickname = nickname
	
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
	return monster.moves[index]


func use_monster_move(monster: Monster, move: Move) -> void:
	# If no move usages or hp left, don't use move
	if move.usages <= 0 or monster.hp == 0:
		return
	
	# Check if there are any move usages remaining
	if move.usages > 0:
		# Show log message showing monster and move
		var use_message: String = move.use_message.format({"user_name": monster.species_name, "move_name": move.move_name})
		Events.request_log.emit(use_message)
		
		# End turn if move has been blocked by condition
		if monster.move_blocked:
			Events.request_log.emit("But it can't move!")
			monster.move_blocked = false
			return
		
		# Subtract a usage when move is used
		move.usages -= 1
		
		# Save boolean that checks if a move hits (if random number is less than
		# base accuracy, then it hits 
		var hit: bool = rng.randf() < move.base_accuracy
		
		var crit: bool = rng.randf() < Calculations.get_critical_chance(monster)
		
		if crit:
			Events.request_log.emit("Critial hit!")
		
		# Show message if move doesn't hit
		if !hit:
			Events.request_log.emit("The move missed!")
		
		# If effect hits, proceed to use effect(s)
		for effect: TargetedEffect in move.resource.use_effects:
			if effect.should_do(hit, crit):
				effect._do(monster, move, crit, game_state, rng)


# Function to add/subtract hp to/from monster
func adjust_monster_hp(monster: Monster, amount: int) -> void:
	# Clamp value to ensure it stays between 0 and max HP
	monster.hp = clamp(monster.hp + amount, 0, monster.max_hp)
	
	if monster.hp == 0:
		faint_monster(monster)
	# Update UI
	Events.on_monster_updated.emit(monster)


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
	
	# Update UI
	Events.on_monster_updated.emit(monster)


func end_condition(monster: Monster, condition: Condition) -> void:
	monster.conditions.remove_at(monster.conditions.find(condition))
	
	# Update UI
	Events.on_monster_updated.emit(monster)


func do_monster_turn(monster: Monster) -> void:
	on_turn_begun(monster)
	use_monster_move(monster, monster.chosen_move)
	monster.chosen_move = null


func on_turn_begun(monster: Monster) -> void:
	if monster.hp == 0:
		return
	for condition: Condition in monster.conditions:
		for effect in condition.resource.on_begin_turn_effects:
			# No crits for conditions, so hardcoded as false
			effect._do(monster, condition, false, game_state, rng)
		condition.duration_remaining -= 1
		if condition.duration_remaining <= 0:
			end_condition(monster, condition)
