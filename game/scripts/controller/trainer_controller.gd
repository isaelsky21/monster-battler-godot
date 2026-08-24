class_name TrainerController extends RefCounted

var game_state: GameState
var rng: RandomNumberGenerator


func _init(state: GameState, random_number_generator: RandomNumberGenerator) -> void:
	game_state = state
	rng = random_number_generator


func create_trainer(monsters: Array[Monster], is_player: bool = false) -> Trainer:
	var trainer: Trainer = Trainer.new()
	trainer.is_player = is_player
	trainer.monsters = monsters
	add_trainer_monster_to_battle(trainer, 0)
	return trainer


func add_trainer_monster_to_battle(trainer: Trainer, monster_index: int) -> void:
	var monster: Monster = trainer.monsters[monster_index]
	trainer.active_monster_index = monster_index
	Events.on_monster_added_to_battle.emit(monster, trainer.is_player)
