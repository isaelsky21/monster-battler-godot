class_name MoveResource extends Resource

@export var move_name: String
@export var max_usages: int
@export var use_effects: Array[TargetedEffect]
@export var type: MonsterType.Type
@export var use_message: String = "{user_name} used {move_name}"
@export_range(0, 1, 0.1) var base_accuracy: float = 0.9
@export var move_priority: int
@export var use_avfx: Array[AVFXResource]
