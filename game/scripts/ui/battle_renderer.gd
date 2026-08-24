extends Control

@export var player_mon_module: MonsterRendererModule
@export var enemy_mon_module: MonsterRendererModule
@export var player_mon_state_dump: MonsterDataDump
@export var enemy_mon_state_dump: MonsterDataDump

func _ready() -> void:
	# Connect signal listeners
	Events.on_battle_is_setup.connect(render)
	Events.on_battle_is_setup.emit()
	
	# Once listeners are connected, we need to emit an event to unblock gameplay
	Events.on_ui_ready.emit()
	
	
func render() -> void:
	player_mon_module.your_pov = true
	
	player_mon_module.connect_events()
	enemy_mon_module.connect_events()
	player_mon_state_dump.connect_events()
	enemy_mon_state_dump.connect_events()
