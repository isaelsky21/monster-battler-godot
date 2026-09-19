class_name Trainer

var trainer_name: String
var monsters: Array[Monster] = []
var items: Array[Item] = []
var active_monster_index: int = 0
var is_player: bool

var chosen_action_type: GameRunner.INTERACTION_MODE = GameRunner.INTERACTION_MODE.NONE
var chosen_action_index: int = -1

var active_monster: Monster:
	get: return monsters[active_monster_index]
