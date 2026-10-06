class_name TrainerStartState
extends Resource

@export var trainer_name: String
@export var monsters: Array[MonsterStartState] = []
@export var items: Array[ItemStartState] = []


func generate_trainer(
	is_player: bool,
	monster_controller: MonsterController,
	trainer_controller: TrainerController
) -> Trainer:
	var generated_monsters: Array[Monster] = []
	
	for monster_start_state: MonsterStartState in monsters:
		var monster: Monster = monster_start_state.generate(
			monster_controller
		)
		
		generated_monsters.append(monster)
	
	var trainer: Trainer = trainer_controller.create_trainer(
		generated_monsters,
		is_player
	)
	
	trainer.trainer_name = trainer_name
	
	for item_start_state: ItemStartState in items:
		trainer_controller.add_item(
			trainer,
			item_start_state.resource,
			item_start_state.quantity
		)
	
	return trainer
