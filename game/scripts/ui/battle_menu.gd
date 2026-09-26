extends Control
## Parent control node that handles selecting the different options

# Buttons
@export var select_fight: Button
@export var select_run: Button
@export var select_mon: Button
@export var select_item: Button
@export var select_back: Button
# Menus
@export var main_menu: Control
@export var fight_menu: OptionPanel
@export var item_menu: OptionPanel
@export var monster_menu: OptionPanel


func _ready() -> void:
	# Connect button signals to GameRunner functions that handle what happens
	# with each action
	select_fight.pressed.connect(Events.request_menu_fight.emit)
	select_mon.pressed.connect(Events.request_menu_monsters.emit)
	select_item.pressed.connect(Events.request_menu_items.emit)
	
	# Any time an option is successfully selected, we want to return to main.\
	# Underscored variables ignored.
	Events.request_option_selected.connect(\
		func(_mode: GameRunner.INTERACTION_MODE, _index: int) -> void:\
			handle_select_main())
	
	# At the end of each request_menu_ function in GameRunner is a signal
	# emission that calls the specific function below depending on the action
	Events.on_menu_fight.connect(handle_select_action.bind(fight_menu))
	Events.on_menu_select_monster.connect(handle_select_action.bind(monster_menu))
	Events.on_menu_items.connect(handle_select_action.bind(item_menu))
	
	# Back and Run button presses are handled in this class
	select_back.pressed.connect(handle_select_main)
	select_run.pressed.connect(handle_select_run)
	
	# After losing, hide battle menu, when a new game starts, show it
	Events.on_game_over.connect(func(_b: bool) -> void: hide())
	Events.on_new_game_state.connect(show)

	# Activate the main menu 
	handle_select_main()


### Hides all menus, but Main
func handle_select_main() -> void:
	hide_all()
	main_menu.show()


### TODO: We will want to block interaction at some point. We can use this
## for that.
func is_interaction_blocked() -> bool:
	return false


### Hides all menus. Useful since we only want one to show one at a time.
func hide_all() -> void:
	main_menu.hide()
	fight_menu.hide()
	select_back.hide()
	monster_menu.hide()
	item_menu.hide()


### Disables all buttons, except Action and Back, and populates options list
func handle_select_action(labels: Array[StringEnabled],\
		option_panel: OptionPanel) -> void:
	if is_interaction_blocked():
		return
	hide_all()
	option_panel.show()
	select_back.show()
	
	option_panel.populate(labels)


### Since we only have battles and no overworld in this prototype,
## running means quitting.
func handle_select_run() -> void:
	if is_interaction_blocked():
		return

	Events.request_quit.emit()
