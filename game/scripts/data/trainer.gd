class_name Trainer

var trainer_name: String
var monsters: Array[Monster] = []
var active_monster_index: int = 0
var is_player: bool

var active_monster: Monster:
	get: return monsters[active_monster_index]
