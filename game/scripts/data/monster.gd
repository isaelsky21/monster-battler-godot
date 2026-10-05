class_name Monster

var species: SpeciesResource
var nickname: String
# Monster hitpoints
var hp: int
# Total experience
var experience: int
# Current level
var level: int = 1

## MOVES
# Max amount of moves at a time
var max_moves: int = 4
# List of moves the monster knows
var moves: Array[Move] = []
# Pending moves to learn
var pending_moves: Array[MoveResource] = []
# Move to to learn if replacing when learning a new move
var pending_move: MoveResource
# Move used when out of moves
var fallback_move: Move
# Ephemeral state, cleared after each turn
# Move successfully blocked by condition
var move_blocked: bool

# List of conditions applied to monster
var conditions: Array[Condition] = []

# Stat changes based on levels attained
var hp_growth: float
var attack_growth: float
var defense_growth: float
var special_attack_growth: float
var special_defense_growth: float
var speed_growth: float


# Getters
var image: Texture2D:
	get: return species.image

var species_name: String:
	get: return nickname if nickname else species.species_name

var type: MonsterType.Type:
	get: return species.type

var max_level: int:
	get: return species.base_max_level

var max_hp: int:
	get: return Calculations.calculate_monster_stat(species.base_max_hp,\
	hp_growth, level, sum_condition_stats_for_code(Stat.Code.MAX_HP))

var attack: int:
	get: return Calculations.calculate_monster_stat(species.base_attack,\
	attack_growth, level, sum_condition_stats_for_code(Stat.Code.ATK))

var defense: int:
	get: return Calculations.calculate_monster_stat(species.base_defense,\
	defense_growth, level, sum_condition_stats_for_code(Stat.Code.DEF))

var special_attack: int:
	get: return Calculations.calculate_monster_stat(species.base_special_attack,\
	special_attack_growth, level, sum_condition_stats_for_code(Stat.Code.SPATK))

var special_defense: int:
	get: return Calculations.calculate_monster_stat(species.base_special_defense,\
	special_defense_growth, level, sum_condition_stats_for_code(Stat.Code.SPDEF))

var speed: int:
	get: return Calculations.calculate_monster_stat(species.base_speed,\
	speed_growth, level, sum_condition_stats_for_code(Stat.Code.SPD))


# Go through moves list, add usable moves to variable, and return
func get_legal_move_indices() -> Array[int]:
	var legal_indices: Array[int] = []
	
	for i in range(0, moves.size()):
		if moves[i] and moves[i].usages > 0:
			legal_indices.append(i)
	
	return legal_indices


func adjust_hp(amount: int) -> void:
	hp = clampi(hp + amount, 0, max_hp)


func is_fainted() -> bool:
	return hp <= 0


func add_condition(condition_resource: ConditionResource) -> bool:
	var current_stacks: int = conditions.filter(
		func(condition_to_check: Condition) -> bool:
			return condition_to_check.resource == condition_resource
	).size()
	
	if current_stacks >= condition_resource.max_stacks:
		return false
	
	var condition: Condition = Condition.new()
	condition.resource = condition_resource
	condition.duration_remaining = condition_resource.duration
	
	conditions.append(condition)
	
	return true


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
		return ""
	else:
		return conditions[0].short_name


# To show stats in UI
func dump_state() -> String:
	var condition_string: String = ""
	
	for condition: Condition in conditions:
		condition_string += "{name} - ({remaining})\n"\
		.format({
			"name": condition.condition_name,
			"remaining": condition.duration_remaining
		})
	
	return "Name: {name}\nHP: {hp}/{max_hp}\nAttack: {attack}\nDefense: {defense}\nSpecial Attack: {special_attack}\nSpecial Defense: {special_defense} \nSpeed: {speed} \nConditions: {conditions}"\
	.format({
		"name": species_name,
		"max_hp": max_hp,
		"hp": hp,
		"attack": attack,
		"defense": defense,
		"special_attack": special_attack,
		"special_defense": special_defense,
		"speed": speed,
		"conditions": condition_string,
	})
