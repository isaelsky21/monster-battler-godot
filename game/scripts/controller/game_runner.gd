extends Node

# The main script that controls the flow of the game.

# INTERACTION_MODE encodes the menu states the main battle menu can be in.
# Since RUN isn't a special menu, it does not get an entry here
enum INTERACTION_MODE {NONE, FIGHT, ITEM, MON}

# Turn state machine
enum PHASE {AWAIT_INPUT, RESOLVE_ROUND}
var current_phase: PHASE

var default_fallback_move: Resource = preload("res://content/moves/struggle.tres")

var game_state: GameState
var rng: RandomNumberGenerator


func _ready() -> void:
	# Connect signal listeners
	Events.request_menu_fight.connect(handle_request_menu_fight)
	Events.request_menu_monsters.connect(handle_request_menu_monsters)
	Events.request_option_selected.connect(handle_menu_option_selected)
	Events.request_quit.connect(handle_run)
	Events.on_ui_ready.connect(set_up_model)


func _process(_delta: float) -> void:
	if current_phase == PHASE.AWAIT_INPUT:
		# Player uses a move
		if game_state.player_monster.chosen_move != null:
			current_phase = PHASE.RESOLVE_ROUND
		# Opponent uses a move
		if game_state.opponent_monster.chosen_move == null:
			game_state.opponent_monster.chosen_move = choose_opponent_move()
	elif current_phase == PHASE.RESOLVE_ROUND:
		resolve_round()
		current_phase = PHASE.AWAIT_INPUT


func set_up_model() -> void:
	game_state = GameState.new()
	rng = RandomNumberGenerator.new()
	
	var species_salamander: Resource = preload("res://content/species/salamander.tres")
	var species_turtle: Resource = preload("res://content/species/turtle.tres")
	var species_dino: Resource = preload("res://content/species/dino.tres")
	
	var monster_controller: MonsterController = MonsterController.new(game_state, rng)
	
	var monster1: Monster = monster_controller.create_monster(species_salamander, "CharChar")
	var monster2: Monster = monster_controller.create_monster(species_turtle, "Squerol")
	var monster3: Monster = monster_controller.create_monster(species_dino, "Diva")
	
	var trainer_controller: TrainerController = TrainerController.new(game_state, rng)
	
	game_state.player = trainer_controller.create_trainer([monster1, monster3], true)
	game_state.opponent = trainer_controller.create_trainer([monster2])


func handle_request_menu_fight() -> void:
	var labels: Array[StringEnabled] = []
	
	for move in game_state.player.active_monster.moves:
		var label: StringEnabled = StringEnabled.new(move.resource.move_name, move.usages > 0)
		labels.append(label)
	
	Events.on_menu_fight.emit(labels)


func handle_request_menu_monsters() -> void:
	var labels: Array[StringEnabled] = []
	for monster in game_state.player.monsters:
		labels.append(StringEnabled.new(monster.species_name, monster.hp > 0))
	Events.on_menu_select_monster.emit(labels)


func handle_menu_option_selected(mode: INTERACTION_MODE, index: int) -> void:
	# Only handles player case
	match(mode):
		INTERACTION_MODE.MON:
			var trainer_controller: TrainerController = TrainerController.new(game_state, rng)
			trainer_controller.add_trainer_monster_to_battle(game_state.player, index)
		INTERACTION_MODE.FIGHT:
			var monster_controller: MonsterController = MonsterController.new(game_state, rng)
			game_state.player_monster.chosen_move = monster_controller.get_monster_move_at_index(game_state.player.active_monster, index)


func handle_run() -> void:
	Events.request_log.emit("You ran away!")
	await get_tree().create_timer(2.0).timeout
	get_tree().quit()


func choose_opponent_move() -> Move:
	# If no moves, show log and end turn
	var legal_move_indices: Array[int] = game_state.opponent_monster.get_legal_move_indices()
	if legal_move_indices.size() <= 0:
		Events.request_log.emit("Out of moves. Using default.")
		return game_state.opponent_monster.fallback_move
	else:
		# Save move index from opponent moves list
		var move_index: int = legal_move_indices.pick_random()
		# Create MonsterController instance and call function
		var monster_controller: MonsterController = MonsterController.new(game_state, rng)
		return monster_controller.get_monster_move_at_index(game_state.opponent_monster, move_index)


func resolve_round() -> void:
	# First turn based on player/opponent speed
	var player_goes_first: bool = does_player_go_first(game_state.player_monster, game_state.opponent_monster)
	var monster_controller: MonsterController = MonsterController.new(game_state, rng)
	
	if player_goes_first:
		monster_controller.do_monster_turn(game_state.player_monster)
		monster_controller.do_monster_turn(game_state.opponent_monster)
	else:
		monster_controller.do_monster_turn(game_state.opponent_monster)
		monster_controller.do_monster_turn(game_state.player_monster)


# Handles move priority
func does_player_go_first(player_monster: Monster, opponent_monster: Monster) -> bool:
	assert(player_monster.chosen_move != null)
	assert(opponent_monster.chosen_move != null)
	
	if player_monster.chosen_move.move_priority > opponent_monster.chosen_move.move_priority:
		return true
	elif player_monster.chosen_move.move_priority < opponent_monster.chosen_move.move_priority:
		return false
	else:
		return game_state.player_monster.speed >= game_state.opponent_monster.speed
