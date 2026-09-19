class_name ConditionResource
extends Resource

@export var condition_name: String
@export var stat_modifiers: Array[StatModifier]
@export var on_begin_turn_effects: Array[TargetedEffect]
@export var on_begin_turn_avfx: Array[AVFXResource]
# Number of turns condition will last for
@export var duration: int
# How many versions of condition type can exist on one monster
@export var max_stacks: int = 1
# Condition name that shows under HP bar
@export var short_name: String
