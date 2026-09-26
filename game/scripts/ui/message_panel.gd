class_name MessagePanel
extends Panel

@export var label: TypeoutLabel
@export var choice_parent: Control
@export var message_queue: Array[MessageResource] = []
@export var instance_queue: Array[AVFXInstance] = []

var current_message: MessageResource = null
var current_instance: AVFXInstance


func _ready() -> void:
	Events.on_avfx_messages.connect(queue_messages)


func _input(event: InputEvent) -> void:
	if current_message != null\
		and current_message.choices.size() == 0\
		and event is InputEventMouseButton\
		and event.button_index == MOUSE_BUTTON_LEFT\
		and event.pressed:
			dismiss_message()


func queue_messages(instance: AVFXInstance) -> void:
	Events.on_message_panel_start.emit()
	if current_instance == null:
		run_instance(instance)
	else:
		instance_queue.append(instance)


func show_message(message: MessageResource) -> void:
	current_message = message
	label.populate(message.text)
	
	for child in choice_parent.get_children():
		# Clear old children
		child.queue_free()
	
	for choice in current_message.choices:
		var choice_button: Button = Button.new()
		choice_parent.add_child(choice_button)
		choice_button.text = choice.text
		choice_button.pressed.connect(func() -> void: do_choice(choice.function))


func dismiss_message() -> void:
	current_message = null
	
	if message_queue.size() == 0:
		if current_instance != null:
			current_instance.finish()
			current_instance = null
			
			if instance_queue.size() > 0:
				run_instance(instance_queue.pop_front())
			else:
				Events.on_message_panel_end.emit()
	else:
		show_message(message_queue.pop_front())


func run_instance(instance: AVFXInstance) -> void:
	current_instance = instance
	message_queue = []
	for message in instance.resource.messages:
		message_queue.append(message)
	
	if current_message == null:
		show_message(message_queue.pop_front())


func do_choice(choice: Callable) -> void:
	# dismiss_message has to be called first
	dismiss_message()
	choice.call()
