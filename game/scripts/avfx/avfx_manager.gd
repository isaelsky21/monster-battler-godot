extends Node

var active_effect_count: int
var effect_group_queue: Array[Node]
var current_effect_group: Node
var active: bool


func _process(_delta: float) -> void:
	if active and current_effect_group == null:
		if effect_group_queue.size() == 0:
			Events.on_avfx_block_end.emit()
			active = false
		else:
			current_effect_group = effect_group_queue.pop_front()
			active_effect_count = current_effect_group.get_children().size()
			
			for avfx_instance: AVFXInstance in current_effect_group.get_children():
				avfx_instance.execute()
			call_deferred("emit_block_start")


# Add effect to the list
func queue_avfx_effect_group(resources: Array[AVFXResource], monster: Monster, game_state: GameState) -> void:
	active = true
	var group: Node = Node.new()
	add_child(group)
	effect_group_queue.append(group)
	for resource: AVFXResource in resources:
		var monster_controller: MonsterController = MonsterController.new(game_state)
		var target: Monster = monster if resource.target_self else monster_controller.get_opposing_monster(monster)
		
		var instance: AVFXInstance = resources[0].generate(target)
		group.add_child(instance)
		instance.name = resource.get_script().get_global_name()


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
