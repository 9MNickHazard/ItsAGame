extends CanvasLayer

@onready var volume_slider: HSlider = $VolumeSlider
@onready var restart_button: Button = $RestartButton
@onready var quit_button: Button = $QuitButton
@onready var real_pause_menu: CanvasLayer = $"."
@onready var keybind_container: VBoxContainer = $TabContainer/Controls/ScrollContainer/VBoxContainer
@onready var default_button: Button = $TabContainer/Controls/ResetControls



var actions = ["left", "right", "up", "down", "left_click", "Blink", "Ability 1", "pause", "scroll_up", "scroll_down"]
var action_display_names = {
	"left": "Move Left",
	"right": "Move Right", 
	"up": "Move Up",
	"down": "Move Down",
	"left_click": "Shoot",
	"Blink": "Blink",
	"Ability 1": "Shockwave",
	"pause": "Pause",
	"scroll_up": "Next Weapon",
	"scroll_down": "Previous Weapon"
}

var waiting_for_input = false
var action_to_remap = null
var original_events = {}

func _ready() -> void:
	real_pause_menu.hide()
	
	volume_slider.value = 1
	volume_slider.value_changed.connect(_on_volume_slider_value_changed)
	default_button.pressed.connect(_reset_to_defaults)
	
	# Store original keybinds as a backup
	_backup_original_keybinds()
	
	# Create the UI
	_create_keybind_ui()

func _backup_original_keybinds():
	# Store the original keybinds
	for action in actions:
		original_events[action] = InputMap.action_get_events(action).duplicate()
	
func _create_keybind_ui():
	# Clear existing keybind UI
	for child in keybind_container.get_children():
		child.queue_free()
	
	# Create UI for each action
	for action in actions:
		var hbox = HBoxContainer.new()
		hbox.set_h_size_flags(Control.SIZE_FILL)
		
		var label = Label.new()
		label.text = action_display_names[action]
		label.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		
		var button = Button.new()
		button.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		
		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			if events[0] is InputEventKey:
				button.text = events[0].as_text()
			elif events[0] is InputEventMouseButton:
				button.text = _get_mouse_button_string(events[0].button_index)
		else:
			button.text = "None"
		
		button.pressed.connect(_on_button_pressed.bind(action, button))
		
		hbox.add_child(label)
		hbox.add_child(button)
		keybind_container.add_child(hbox)

func _get_mouse_button_string(button_index):
	match button_index:
		MOUSE_BUTTON_LEFT: return "Left Mouse Button"
		MOUSE_BUTTON_RIGHT: return "Right Mouse Button"
		MOUSE_BUTTON_MIDDLE: return "Middle Mouse Button"
		MOUSE_BUTTON_WHEEL_UP: return "Mouse Wheel Up"
		MOUSE_BUTTON_WHEEL_DOWN: return "Mouse Wheel Down"
		_: return "Mouse Button " + str(button_index)

func _on_button_pressed(action, button):
	waiting_for_input = true
	action_to_remap = action
	button.text = "Press any key..."

func _input(event):
	if event.is_action_pressed("pause") and not waiting_for_input:
		toggle_pause()
	
	elif waiting_for_input:
		if event is InputEventKey or event is InputEventMouseButton:
			# Cancel if Escape is pressed
			if event is InputEventKey and event.keycode == KEY_ESCAPE:
				waiting_for_input = false
				_create_keybind_ui()
				return
			
			# Only handle the event if it's a press, not a release
			if event.pressed:
				# Make a backup of the current events for this action
				var old_events = InputMap.action_get_events(action_to_remap).duplicate()
				
				# Erase the old binding
				InputMap.action_erase_events(action_to_remap)
				
				# Add the new binding
				InputMap.action_add_event(action_to_remap, event)
				
				# Verify the action works - if not, restore the old binding
				if InputMap.action_get_events(action_to_remap).size() == 0:
					print("ERROR: Failed to set new keybind for ", action_to_remap)
					for old_event in old_events:
						InputMap.action_add_event(action_to_remap, old_event)
				
				# Update UI and reset state
				waiting_for_input = false
				action_to_remap = null
				_create_keybind_ui()
				
				get_viewport().set_input_as_handled()

func _reset_to_defaults():
	# Restore original keybinds
	for action in actions:
		if original_events.has(action):
			# Clear current bindings
			InputMap.action_erase_events(action)
			
			# Add original bindings back
			for event in original_events[action]:
				InputMap.action_add_event(action, event)
	
	# Update the UI
	_create_keybind_ui()
	
func _on_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(value))

func toggle_pause():
	var normal_pause_menu = get_node("/root/world/PauseMenu")
	
	if normal_pause_menu and normal_pause_menu.visible:
		return
	
	if real_pause_menu.visible:
		real_pause_menu.hide()
		get_tree().paused = false
	else:
		real_pause_menu.show()
		get_tree().paused = true
		
func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_restart_button_pressed() -> void:
	var BulletScript = load("res://scripts/bullet.gd")
	BulletScript.damage_min_bonus = 0.0
	BulletScript.damage_max_bonus = 0.0
	BulletScript.speed_bonus = 0.0
	BulletScript.range_bonus = 0.0
	
	var Bullet2Script = load("res://scripts/bullet_2.gd")
	Bullet2Script.damage_min_bonus = 0.0
	Bullet2Script.damage_max_bonus = 0.0
	Bullet2Script.speed_bonus = 0.0
	Bullet2Script.range_bonus = 0.0
	
	var SniperBulletScript = load("res://scripts/sniper_1_bullet.gd")
	SniperBulletScript.damage_min_bonus = 0.0
	SniperBulletScript.damage_max_bonus = 0.0
	SniperBulletScript.speed_bonus = 0.0
	SniperBulletScript.range_bonus = 0.0
	
	var FireBlinkScript = load("res://scripts/fire_blink.gd")
	FireBlinkScript.damage_min_bonus = 0
	FireBlinkScript.damage_max_bonus = 0
	
	var RocketAmmoScript = load("res://scripts/rocket_ammo.gd")
	RocketAmmoScript.damage_min_bonus = 0.0
	RocketAmmoScript.damage_max_bonus = 0.0
	RocketAmmoScript.speed_bonus = 0.0
	RocketAmmoScript.range_bonus = 0.0
	
	var ShockwaveScript = load("res://scripts/shockwave.gd")
	ShockwaveScript.damage = 10.0
	ShockwaveScript.knockback_amount = 200.0
	
	var PlayerScript = load("res://scripts/player.gd")
	PlayerScript.blink_distance = 300.0
	PlayerScript.BLINK_SPEED = 1500.0
	PlayerScript.max_mana = 100.0
	PlayerScript.max_health = 100.0
	
	CoinPoolManager.reset_for_new_game()
	get_tree().paused = false
	get_tree().reload_current_scene()
