extends ScrollContainer

@export var content_container: Control

func _ready() -> void:
	# Connect signal listeners
	Events.request_log.connect(log)
	Events.on_new_game_state.connect(clear)
	

func log(text: String) -> void:
	# Log simply spawns a new label in the log and scrolls to it. Great for seeing what's happening.
	var label: TypeoutLabel = TypeoutLabel.new()
	content_container.add_child(label)
	label.populate(text)
	call_deferred("scroll_bottom")

func scroll_bottom() -> void:
	set_deferred("scroll_vertical", get_v_scroll_bar().max_value)


func clear() -> void:
	for child in content_container.get_children():
		child.queue_free()
