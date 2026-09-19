extends Node

# The main script that controls the flow of the game.

# INTERACTION_MODE encodes the menu states the main battle menu can be in.
# Since RUN isn't a special menu, it does not get an entry here
enum INTERACTION_MODE {NONE, FIGHT, ITEM, MON}

# Turn state machine
enum PHASE {AWAIT_INPUT, RESOLVE_ROUND, AWAIT_AVFX, GAME_OVER}
var current_phase: PHASE

var default_fallback_move: Resource = preload("res://content/moves/struggle.tres")

var game_state: GameState
var rng: RandomNumberGenerator

var trainer_controller: TrainerController
var monster_controller: MonsterController


func _ready() -> void:
	# Connect signal listeners
	Events.request_menu_fight.connect(handle_request_menu_fight)
	Events.request_menu_monsters.connect(handle_request_menu_monsters)
	Events.request_menu_items.connect(handle_request_menu_items)
	Events.request_option_selected.connect(handle_menu_option_selected)
	Events.request_restart.connect(handle_restart)
	Events.request_quit.connect(handle_run)
	Events.on_avfx_block_start.connect(func() -> void: current_phase = PHASE.AWAIT_AVFX)
	Events.on_avfx_block_end.connect(func() -> void: current_phase = PHASE.AWAIT_INPUT)
	
	Events.on_ui_ready.connect(set_up_model)


func _process(_delta: float) -> void:
	if current_phase == PHASE.AWAIT_INPUT:
		# Player uses a move
		if game_state.player.chosen_action_type != INTERACTION_MODE.NONE:
			current_phase = PHASE.RESOLVE_ROUND
		# Opponent uses a move
		if game_state.opponent.chosen_action_type == INTERACTION_MODE.NONE:
			choose_opponent_move()
	elif current_phase == PHASE.RESOLVE_ROUND:
		resolve_round()
		if current_phase != PHASE.GAME_OVER:
			current_phase = PHASE.AWAIT_INPUT
	elif current_phase == PHASE.AWAIT_AVFX:
		return
	else:
		return


func set_up_model() -> void:
	game_state = GameState.new()
	rng = RandomNumberGenerator.new()
	
	Events.on_new_game_state.emit()
	
	# Initialize controllers for use throughout script
	monster_controller = MonsterController.new(game_state, rng)
	trainer_controller = TrainerController.new(monster_controller, game_state, rng)
	
	var species_salamander: Resource = preload("res://content/species/salamander.tres")
	var species_turtle: Resource = preload("res://content/species/turtle.tres")
	var species_dino: Resource = preload("res://content/species/dino.tres")
	
	var monster1: Monster = monster_controller.create_monster(species_salamander, "CharChar")
	var monster2: Monster = monster_controller.create_monster(species_turtle, "Squerol")
	var monster3: Monster = monster_controller.create_monster(species_dino, "Diva")
	
	game_state.player = trainer_controller.create_trainer([monster1, monster3], true)
	game_state.opponent = trainer_controller.create_trainer([monster2])
	# Temp names
	game_state.player.trainer_name = "Red"
	game_state.opponent.trainer_name = "Blue"
	
	var item_resource: ItemResource = preload("res://content/items/potion.tres")
	trainer_controller.add_item(game_state.player, item_resource, 2)
	trainer_controller.add_item(game_state.player, item_resource, 1)
	
	# Re-enables buttons
	current_phase = PHASE.AWAIT_INPUT
	
	#TODO: EITHER GET AVFXINSTANCE OR REMOVE
	# Play sound when entering battle
	#var clip: Resource = preload("res://assets/sound/Game_SFX_by_OwlishMedia/birdchirp2.wav")
	#Events.on_avfx_sfx.emit(clip)


func handle_request_menu_fight() -> void:
	if current_phase != PHASE.AWAIT_INPUT:
		return
	var labels: Array[StringEnabled] = []
	
	for move in game_state.player.active_monster.moves:
		var label: StringEnabled = StringEnabled.new(move.resource.move_name, move.usages > 0)
		labels.append(label)
	
	if labels.any(func(label: StringEnabled): return label.enabled):
		Events.on_menu_fight.emit(labels)
	else:
		# Fall back to default move
		trainer_controller.set_current_monster_move(game_state.player, -1)


func handle_request_menu_monsters() -> void:
	if current_phase != PHASE.AWAIT_INPUT:
		return
	var labels: Array[StringEnabled] = []
	for monster in game_state.player.monsters:
		labels.append(StringEnabled.new(monster.species_name, monster.hp > 0))
	Events.on_menu_select_monster.emit(labels)


func handle_request_menu_items() -> void:
	if current_phase != PHASE.AWAIT_INPUT:
		return
	var labels: Array[StringEnabled] = []
	for item in game_state.player.items:
		labels.append(StringEnabled.new(item.item_name + " x" + str(item.quantity), item.quantity != 0))
	Events.on_menu_items.emit(labels)


func handle_menu_option_selected(mode: INTERACTION_MODE, index: int) -> void:
	if current_phase != PHASE.AWAIT_INPUT:
		return
	# Only handles player case
	match(mode):
		INTERACTION_MODE.MON:
			trainer_controller.set_add_trainer_monster_to_battle(game_state.player, index)
		INTERACTION_MODE.FIGHT:
			trainer_controller.set_current_monster_move(game_state.player, index)
		INTERACTION_MODE.ITEM:
			trainer_controller.set_use_item_at_index(game_state.player, index)


func handle_restart() -> void:
	set_up_model()


func handle_run() -> void:
	if current_phase != PHASE.AWAIT_INPUT:
		return
	AVFXManager.queue_avfx_message("You ran away!", game_state)
	await get_tree().create_timer(2.0).timeout
	get_tree().quit()


func choose_opponent_move() -> void:
	# If no moves, show log and end turn
	var legal_move_indices: Array[int] = game_state.opponent_monster.get_legal_move_indices()
	if legal_move_indices.size() <= 0:
		AVFXManager.queue_avfx_message("Out of moves. Using default.", game_state)
		trainer_controller.set_current_monster_move(game_state.opponent, -1)
	else:
		# Save move index from opponent moves list
		var move_index: int = legal_move_indices.pick_random()
		# Use monster move
		trainer_controller.set_current_monster_move(game_state.opponent, move_index)


func resolve_round() -> void:
	# First turn based on player/opponent speed
	var player_goes_first: bool = does_player_go_first()
	
	if player_goes_first:
		trainer_controller.do_trainer_turn(game_state.player)
		trainer_controller.do_trainer_turn(game_state.opponent)
	else:
		trainer_controller.do_trainer_turn(game_state.opponent)
		trainer_controller.do_trainer_turn(game_state.player)
	
	if game_state.player_monster.hp == 0:
		var next_index: int = trainer_controller.get_next_usable_monster_index(game_state.player)
		if next_index == -1:
			current_phase = PHASE.GAME_OVER
			Events.on_game_over.emit(false)
		else:
			trainer_controller.set_add_trainer_monster_to_battle(game_state.player, next_index)
	if game_state.opponent_monster.hp == 0:
		var next_index: int = trainer_controller.get_next_usable_monster_index(game_state.opponent)
		if next_index == -1:
			current_phase = PHASE.GAME_OVER
			Events.on_game_over.emit(true)
		else:
			trainer_controller.set_add_trainer_monster_to_battle(game_state.opponent, next_index)


# Handles move priority
func does_player_go_first() -> bool:
	assert(game_state.player.chosen_action_type != INTERACTION_MODE.NONE)
	assert(game_state.opponent.chosen_action_type != INTERACTION_MODE.NONE)
	
	if game_state.player.chosen_action_type == INTERACTION_MODE.ITEM\
		or game_state.player.chosen_action_type == INTERACTION_MODE.MON:
			return true
	if game_state.opponent.chosen_action_type == INTERACTION_MODE.ITEM\
		or game_state.opponent.chosen_action_type == INTERACTION_MODE.MON:
			return true
	
	var player_move: Move = monster_controller.get_monster_move_at_index(game_state.player.active_monster, game_state.player.chosen_action_index)
	var opponent_move: Move = monster_controller.get_monster_move_at_index(game_state.opponent.active_monster, game_state.opponent.chosen_action_index)
	
	if player_move.move_priority > opponent_move.move_priority:
		return true
	elif player_move.move_priority < opponent_move.move_priority:
		return false
	else:
		return game_state.player_monster.speed >= game_state.opponent_monster.speed
