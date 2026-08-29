class_name MonsterRendererModule extends Control

# This is a UI panel that handles all visuals for a monster in the battle, 
# including its sprite, HP bar and name

@export 
var your_pov: bool

@export 
var frame: Control

@export
var data_panel: Control

@export
var name_label: Label

@export
var hp_label: Label

@export 
var hp_bar: ProgressBar

@export
var status_label: Label

@export
var sprite: Sprite2D

var bound_monster: Monster


func connect_events() -> void:
	Events.on_monster_updated.connect(maybe_update_monster)
	Events.on_monster_added_to_battle.connect(maybe_bind_monster)
	Events.on_avfx_move.connect(move_monster)


func maybe_update_monster(monster: Monster) -> void:
	if monster == bound_monster:
		update()


func maybe_bind_monster(monster: Monster, is_player_monster: bool) -> void:
	if your_pov == is_player_monster:
		bound_monster = monster
		# Move child node to top if player, so it shows left of UI
		move_child(frame, 0 if is_player_monster else 1)
		update()


# Animate monster when attacking
func move_monster(avfx_instance: AVFXInstance, v2fs: Array[Vector2Float]) -> void:
	if avfx_instance.target != bound_monster:
		return
	
	var tween: Tween = get_tree().create_tween()
	
	for v2f in v2fs:
		tween.tween_property(sprite, "offset", v2f.v2, v2f.f)
	
	tween.tween_property(sprite, "offset", Vector2.ZERO, 0.1)
	tween.tween_callback(avfx_instance.finish)

func update() -> void:
	if bound_monster == null:
		return
	
	name_label.text = bound_monster.species_name.to_upper()
	sprite.texture = bound_monster.image
	hp_bar.max_value = bound_monster.max_hp
	hp_bar.value = bound_monster.hp
	hp_label.text = "{hp}\\{max_hp}".format({"hp": bound_monster.hp, "max_hp": bound_monster.max_hp})
	status_label.text = bound_monster.get_condition_string()
