class_name Trainer

var trainer_name: String
var monsters: Array[Monster] = []
var items: Array[Item] = []
var active_monster_index: int = 0
var is_player: bool

var chosen_action_type: GameRunner.INTERACTION_MODE = GameRunner.INTERACTION_MODE.NONE
var chosen_action_index: int = -1

var active_monster: Monster:
	get:
		assert(not monsters.is_empty())
		assert(active_monster_index >= 0)
		assert(active_monster_index < monsters.size())
		return monsters[active_monster_index]
