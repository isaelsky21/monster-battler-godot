class_name TrainerStartState
extends Resource

@export var trainer_name: String
@export var monsters: Array[MonsterStartState]
@export var items: Array[ItemStartState]


func generate_trainer(is_player: bool, monster_controller: MonsterController,\
		game_state: GameState, rng: RandomNumberGenerator) -> Trainer:
			var generated_monsters: Array[Monster] = []
			for monster in monsters:
				generated_monsters.append(monster.generate(game_state, rng))
			
			var trainer_controller: TrainerController = TrainerController.new(\
			monster_controller, game_state, rng)
			
			var trainer: Trainer = trainer_controller.create_trainer(\
			generated_monsters, is_player)
			trainer.trainer_name = trainer_name
			
			for item in items:
				trainer_controller.add_item(trainer, item.resource, item.quantity)
	
			return trainer
