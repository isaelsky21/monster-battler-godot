class_name TrainerController
extends RefCounted

var monster_controller: MonsterController
var game_state: GameState
var rng: RandomNumberGenerator


func _init(p_monster_controller: MonsterController,\
		p_game_state: GameState, p_rng: RandomNumberGenerator) -> void:
	monster_controller = p_monster_controller
	game_state = p_game_state
	rng = p_rng


func create_trainer(monsters: Array[Monster], is_player: bool = false) -> Trainer:
	var trainer: Trainer = Trainer.new()
	trainer.is_player = is_player
	trainer.monsters = monsters
	set_add_trainer_monster_to_battle(trainer, 0)
	return trainer


func do_trainer_turn(trainer: Trainer) -> void:
	monster_controller.on_turn_begun(trainer.active_monster)
	
	match trainer.chosen_action_type:
		GameRunner.INTERACTION_MODE.FIGHT:
			var move: Move = monster_controller.get_monster_move_at_index(trainer.active_monster, trainer.chosen_action_index)
			monster_controller.use_monster_move(trainer.active_monster, move)
		GameRunner.INTERACTION_MODE.MON:
			add_trainer_monster_to_battle(trainer, trainer.chosen_action_index)
		GameRunner.INTERACTION_MODE.ITEM:
			use_item_at_index(trainer, trainer.chosen_action_index)
	
	# Reset trainer's action index so it doesn't get used repeatedly
	trainer.chosen_action_index = -1
	trainer.chosen_action_type = GameRunner.INTERACTION_MODE.NONE


func set_add_trainer_monster_to_battle(trainer: Trainer, index: int) -> void:
	var monster: Monster = trainer.monsters[index]
	
	assert(monster.hp > 0)
	
	trainer.chosen_action_index = index
	trainer.chosen_action_type = GameRunner.INTERACTION_MODE.MON


func add_trainer_monster_to_battle(trainer: Trainer, monster_index: int) -> void:
	var monster: Monster = trainer.monsters[monster_index]
	trainer.active_monster_index = monster_index
	Events.on_monster_added_to_battle.emit(monster, trainer.is_player)


func get_next_usable_monster_index(trainer: Trainer) -> int:
	for index: int in range(trainer.monsters.size()):
		if trainer.monsters[index].hp > 0:
			return index
	
	return -1


func set_current_monster_move(trainer: Trainer, index: int) -> void:
	var monster: Monster = trainer.active_monster
	var move: Move = monster_controller.get_monster_move_at_index(monster, index)
	
	assert(move.usages > 0)
	
	trainer.chosen_action_index = index
	trainer.chosen_action_type = GameRunner.INTERACTION_MODE.FIGHT


func set_use_item_at_index(trainer: Trainer, index: int) -> void:
	var item: Item = trainer.items[index]
	
	assert(item.quantity > 0)
	
	trainer.chosen_action_index = index
	trainer.chosen_action_type = GameRunner.INTERACTION_MODE.ITEM


func use_item_at_index(trainer: Trainer, index: int) -> void:
	var item: Item = trainer.items[index]
	
	if item.quantity <= 0:
		return
	
	var logs: Array[String] = []
	
	var use_message: String = item.use_message.format({"user_name": trainer.trainer_name, "item_name": item.item_name})
	
	var message_avfx: AVFXMessages = AVFXMessages.new(logs as Array[String])
	var avfx_group: Array[AVFXResource] = item.use_avfx.duplicate()
	avfx_group.append(message_avfx)
	AVFXManager.queue_avfx_effect_group(avfx_group, trainer.active_monster, game_state)
	
	if item.consumable:
		remove_item(trainer, item.resource, 1)
	
	for effect: TargetedEffect in item.use_effects:
			if effect.should_do(true, false):
				effect._do(trainer.active_monster, item, false, logs, game_state, rng)


func add_item(trainer: Trainer, item_resource: ItemResource, quantity: int) -> void:
	var existing_item_index: int = trainer.items.find_custom(func(found_item: Item) -> bool: return found_item.resource == item_resource)
	
	# There is no matching item in the trainer's item array
	if existing_item_index == -1:
		var item: Item = Item.new()
		item.resource = item_resource
		item.quantity = quantity
		trainer.items.append(item)
	else:
		var item: Item = trainer.items[existing_item_index]
		item.quantity += 1


func remove_item(trainer: Trainer, item_resource: ItemResource, quantity: int) -> void:
	var existing_item_index: int = trainer.items.find_custom(func(found_item: Item) -> bool: return found_item.resource == item_resource)
	
	assert(existing_item_index > -1)
	
	var item: Item = trainer.items[existing_item_index]
	
	assert(item.quantity >= quantity)
	
	item.quantity -= quantity
	
	if item.quantity == 0:
		trainer.items.remove_at(existing_item_index)
