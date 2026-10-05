extends Control

# UI that displays information about the monster such as HP, image, and name
@export var player_monster_module: MonsterRendererModule
@export var opponent_monster_module: MonsterRendererModule

# Control nodes for each monster to show logs
@export var player_monster_state_dump: MonsterDataDump
@export var opponent_monster_state_dump: MonsterDataDump

@export var controls_menu: Control
@export var message_panel: MessagePanel
@export var move_replace_panel: OptionPanel


func _ready() -> void:
	player_monster_module.your_pov = true
	
	Events.on_avfx_projectile.connect(avfx_projectile)
	Events.on_avfx_animation.connect(avfx_animation)
	Events.on_avfx_flash_screen.connect(avfx_flash_screen)
	Events.on_avfx_shake_screen.connect(avfx_shake_screen)
	
	Events.on_message_panel_start.connect(show_message_panel)
	Events.on_message_panel_end.connect(hide_message_panel)
	Events.on_player_pending_learn_move.connect(show_learn_move_panel)
	Events.on_player_move_replace_completed.connect(hide_learn_move_panel)
	hide_message_panel()
	
	# Once listeners are connected, we need to emit an event to unblock gameplay
	Events.on_ui_ready.emit()


### For getting monster frame holding sprite
func get_monster_frame(monster: Monster) -> Control:
	if player_monster_module.bound_monster == monster:
		return player_monster_module.frame
	elif opponent_monster_module.bound_monster == monster:
		return opponent_monster_module.frame
	return null


func show_message_panel() -> void:
	message_panel.show()
	controls_menu.hide()
	move_replace_panel.hide()


func hide_message_panel() -> void:
	message_panel.hide()
	controls_menu.show()
	move_replace_panel.hide()


func show_learn_move_panel(labels: Array[StringEnabled]) -> void:
	move_replace_panel.show()
	message_panel.hide()
	controls_menu.hide()
	move_replace_panel.populate(labels)


func hide_learn_move_panel() -> void:
	move_replace_panel.hide()
	controls_menu.show()


func avfx_flash_screen(avfx_instance: AVFXInstance, v2s: Array[Vector2]) -> void:
	var tween: Tween = get_tree().create_tween()
	
	tween.tween_property(self, "modulate", Color.WHITE, 0.0)\
		.set_delay(avfx_instance.delay)
	
	for v2: Vector2 in v2s:
		var color: Color = Color(Color.WHITE, v2.x)
		tween.tween_property(self, "modulate", color, v2.y)
	
	tween.tween_property(self, "modulate", Color.WHITE, 0.0)
	tween.tween_callback(avfx_instance.finish)


func avfx_shake_screen(avfx_instance: AVFXInstance, v3s: Array[Vector3]) -> void:
	var tween: Tween = get_tree().create_tween()
	
	tween.tween_property(self, "position", Vector2.ZERO, 0.0)\
		.set_delay(avfx_instance.delay)
	
	for v3: Vector3 in v3s:
		var v2: Vector2 = Vector2(v3.x, v3.y)
		tween.tween_property(self, "position", v2, v3.z)
	
	tween.tween_property(self, "position", Vector2.ZERO, 0.0)
	tween.tween_callback(avfx_instance.finish)


func avfx_projectile(
	instance: AVFXInstance,
	texture: Texture2D,
	sprite_offset: Vector2,
	duration: float
) -> void:
	if instance.delay > 0.0:
		await get_tree().create_timer(instance.delay).timeout
		
		if not is_instance_valid(instance):
			return
	
	do_avfx_projectile(
		instance,
		texture,
		sprite_offset,
		duration
	)


func do_avfx_projectile(
	instance: AVFXInstance,
	texture: Texture2D,
	sprite_offset: Vector2,
	duration: float
) -> void:
	var frame_start: Control = get_monster_frame(instance.target if instance.target_self else instance.user)
	var frame_end: Control = get_monster_frame(instance.user if instance.target_self else instance.target)
	
	if frame_start == null or frame_end == null:
		print("Missing frame for projectile!")
		instance.finish()
		return
	
	var sprite: Sprite2D = Sprite2D.new()
	add_child(sprite)
	sprite.texture = texture
	
	sprite.global_position = get_monster_frame(instance.target if instance.target_self else instance.user).global_position
	
	sprite.offset = sprite_offset
	
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(
		sprite,
		"global_position",
		frame_end.global_position,
		duration)
	tween.tween_callback(func() -> void: clean_up_avfx_node(instance, sprite))


func avfx_animation(
	instance: AVFXInstance,
	animation_scene: PackedScene,
	animation_offset: Vector2
) -> void:
	if instance.delay > 0.0:
		await get_tree().create_timer(instance.delay).timeout
		
		if not is_instance_valid(instance):
			return
		
	do_avfx_animation(
		instance,
		animation_scene,
		animation_offset
	)


func do_avfx_animation(
	instance: AVFXInstance,
	animation_scene: PackedScene,
	animation_offset: Vector2
) -> void:
	var visual_target: Monster = (
		instance.user
		if instance.target_self
		else instance.target
	)
	
	var frame_target: Control = get_monster_frame(visual_target)
	
	if frame_target == null:
		print("Missing frame for animation!")
		instance.finish()
		return
	
	var animation_node: AnimatedSprite2D = animation_scene.instantiate()
	add_child(animation_node)
	animation_node.global_position = frame_target.global_position
	animation_node.sprite_frames.set_animation_loop("default", false)
	animation_node.offset = animation_offset
	animation_node.play()
	animation_node.animation_finished.connect(func() -> void: clean_up_avfx_node(instance, animation_node))


func clean_up_avfx_node(instance: AVFXInstance, node: Node) -> void:
	node.queue_free()
	instance.finish()
