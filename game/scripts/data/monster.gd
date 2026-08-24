class_name Monster

var species: SpeciesResource
var nickname: String
# Monster hitpoints
var hp: int
# List of moves the monster knows
var moves: Array[Move] = []
# Move used when out of moves
var fallback_move: Move
# List of conditions applied to monster
var conditions: Array[Condition]

# Ephemeral state, cleared after each turn
# Move successfully blocked by condition
var move_blocked: bool
var chosen_move: Move

# Getters
var image: Texture2D:
	get: return species.image

var species_name: String:
	get: return nickname if nickname else species.species_name

var type: MonsterType.Type:
	get: return species.type

var max_hp: int:
	get: return clamp(species.base_max_hp + sum_condition_stats_for_code(Stat.Code.MAX_HP), 1, 999)

var attack: int:
	get: return clamp(species.base_attack + sum_condition_stats_for_code(Stat.Code.ATK), 1, 999)

var defense: int:
	get: return clamp(species.base_defense + sum_condition_stats_for_code(Stat.Code.DEF), 1, 999)

var special_attack: int:
	get: return clamp(species.base_special_attack + sum_condition_stats_for_code(Stat.Code.SPATK), 1, 999)

var special_defense: int:
	get: return clamp(species.base_special_defense + sum_condition_stats_for_code(Stat.Code.SPDEF), 1, 999)

var speed: int:
	get: return clamp(species.base_speed + sum_condition_stats_for_code(Stat.Code.SPD), 1, 999)


# Go through moves list, add usable moves to variable and return
func get_legal_move_indices() -> Array[int]:
	var legal_indices: Array[int]
	
	for i in range(0, moves.size()):
		if moves[i] and moves[i].usages > 0:
			legal_indices.append(i)
	
	return legal_indices


func sum_condition_stats_for_code(code: Stat.Code) -> int:
	var sum: int = 0
	for condition: Condition in conditions:
		for stat_modifier: StatModifier in condition.resource.stat_modifiers:
			# Ensures only specific stat is changed
			if stat_modifier.stat == code:
				sum += stat_modifier.modifier
	return sum


# For getting condition short name
func get_condition_string() -> String:
	if conditions.size() == 0:
		return "LevelX"
	else:
		return conditions[0].short_name


# To show stats in UI
func dump_state() -> String:
	var condition_string: String = ""
	var condition_names: Array = []
	
	for condition: Condition in conditions:
		condition_names.append(condition.condition_name)
	
		condition_string += "{name} - ({remaining})\n"\
		.format({"name": condition.condition_name, "remaining": condition.duration_remaining}) #"\n".join(condition_names)
	
	return "Name: {name}\nHP: {hp}/{max_hp}\nAttack: {attack}\nDefense: {defense}\nSpecial Attack: {special_attack}\nSpecial Defense: {special_defense} \nSpeed: {speed} \nConditions: {conditions}"\
	.format({
		"name": species_name,
		"max_hp": hp,
		"hp": max_hp,
		"attack": attack,
		"defense": defense,
		"special_attack": special_attack,
		"special_defense": special_defense,
		"speed": speed,
		"conditions": condition_string,
	})
