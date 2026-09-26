extends Node

var active_effect_count: int
var effect_group_queue: Array[Node]
var current_effect_group: Node
var active: bool
var timeout_timer: Timer

const MAX_GROUP_TIMEOUT: float = 6.0


func _ready() -> void:
	timeout_timer = Timer.new()
	add_child(timeout_timer)
	timeout_timer.wait_time = MAX_GROUP_TIMEOUT
	timeout_timer.timeout.connect(timeout_current_group)
	timeout_timer.one_shot = true
	
	Events.on_message_panel_start.connect(func() -> void: timeout_timer.paused = true)
	Events.on_message_panel_end.connect(func() -> void: timeout_timer.paused = false)


func _process(_delta: float) -> void:
	if active and current_effect_group == null:
		if effect_group_queue.size() == 0:
			timeout_timer.stop()
			Events.on_avfx_block_end.emit()
			active = false
		else:
			timeout_timer.start()
			current_effect_group = effect_group_queue.pop_front()
			active_effect_count = current_effect_group.get_children().size()
			
			for avfx_instance: AVFXInstance in current_effect_group.get_children():
				avfx_instance.execute()
			call_deferred("emit_block_start")


# NOTE: If choices does not have an initial value, it will need to be set
# when calling the function
func queue_avfx_message(message: String, choices: Array[ChoiceResource], game_state: GameState) -> void:
	var message_resource: MessageResource = MessageResource.new(message, choices)
	var messages: AVFXMessages = AVFXMessages.new([message_resource] as Array[MessageResource])
	queue_avfx_effect_group([messages], null, game_state)


# Add effect to the list
func queue_avfx_effect_group(resources: Array[AVFXResource], monster: Monster, game_state: GameState) -> void:
	active = true
	var group: Node = Node.new()
	add_child(group)
	for resource: AVFXResource in resources:
		# Prevent intanciating a null resource
		if resource == null:
			continue
		var monster_controller: MonsterController = MonsterController.new(game_state)
		var target: Monster = monster_controller.get_opposing_monster(monster)
		
		var instance: AVFXInstance = resource.generate(monster, target)
		group.add_child(instance)
		instance.name = resource.get_script().get_global_name()
	
	if group.get_children().size() > 0:
		effect_group_queue.append(group)
	else:
		group.queue_free()


# Delayed function to block input while animation plays
func emit_block_start() -> void:
	Events.on_avfx_block_start.emit()


# Destroy effect after use
func remove_effect(avfx_instance: AVFXInstance) -> void:
	avfx_instance.queue_free()
	
	active_effect_count -= 1
	
	if active_effect_count == 0:
		current_effect_group.queue_free()
		current_effect_group = null


func timeout_current_group() -> void:
	if current_effect_group == null:
		return
	
	for child in current_effect_group.get_children():
		if child.has_method("finish"):
			child.finish()
	
	current_effect_group.queue_free()
	current_effect_group = null
