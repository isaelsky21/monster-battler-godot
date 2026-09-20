class_name MonsterStartState
extends Resource

@export var nickname: String
@export var species: SpeciesResource
@export var level: int


func generate(game_state: GameState, rng: RandomNumberGenerator) -> Monster:
	var monster_controller: MonsterController = MonsterController.new(game_state, rng)
	var monster: Monster = monster_controller.create_monster(species, nickname)
	# Level must be set before hp so that actual hp is calculated properly
	monster.level = level
	monster.hp = monster.max_hp
	
	return monster
