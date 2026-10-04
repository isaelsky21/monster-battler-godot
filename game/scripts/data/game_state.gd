class_name GameState

# Trainers
var player: Trainer
var opponent: Trainer
var is_player_turn: bool

# Getters
var player_monster: Monster:
	get: return player.active_monster
var opponent_monster: Monster:
	get: return opponent.active_monster


func get_opposing_monster(monster: Monster) -> Monster:
	if monster == player_monster:
		return opponent_monster
	
	if monster == opponent_monster:
		return player_monster
	
	return null
