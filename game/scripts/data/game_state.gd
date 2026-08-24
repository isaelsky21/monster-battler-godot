class_name GameState

# Trainers
var player: Trainer
var opponent: Trainer
var is_player_turn: bool
# Monsters
var player_monster: Monster:
	get: return player.active_monster
var opponent_monster: Monster:
	get: return opponent.active_monster
