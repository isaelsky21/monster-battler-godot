class_name Calculations


# Calculates critical chance based on monster speed
static func get_critical_chance(monster: Monster) -> float:
	return clamp(monster.speed / 100.0, 0.01, 0.5)
