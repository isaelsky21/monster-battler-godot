class_name Calculations


# Calculates critical chance based on monster speed
static func get_critical_chance(monster: Monster) -> float:
	return clamp(monster.speed / 100.0, 0.01, 0.5)


# Stat growth per level
static func calculate_monster_stat(base: int, growth: float,\
	level: int, condition_bonus: int) -> int:
	return clamp(base + (level * growth * base / 10.0) + condition_bonus, 1, 999)


# Amount of experience per level
static func experience_for_level(level: int) -> int:
	return 200 * level


# Amount of experience you get for defeating a monster
static func monster_experience_yield(monster: Monster) -> int:
	return 600 * monster.level
