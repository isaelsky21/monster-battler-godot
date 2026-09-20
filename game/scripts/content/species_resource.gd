class_name SpeciesResource
extends Resource

@export var image: Texture2D
@export var species_name: String
@export var starting_moves: Array[MoveResource]
@export var type: MonsterType.Type

@export var base_max_level: int = 100
@export var base_max_hp: int
@export var base_attack: int
@export var base_defense: int
@export var base_special_attack: int
@export var base_special_defense: int
@export var base_speed: int
