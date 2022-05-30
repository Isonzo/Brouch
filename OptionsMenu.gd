extends Control

enum ACTIONS{move_right_, move_left_, jump_, cast_, aim_up_, aim_down_, aim_left_, aim_right_}

var can_change_key: bool = false
var action_string: String

var controller_checked: bool = false

func _input(event):
	if event is InputEventKey:
		if can_change_key:
			_change_key(event)
			can_change_key = false
			_set_keys()

func _ready():
	_set_keys()

func _set_keys():
	for action in ACTIONS:
		var selected_player: String = str($TabContainer/Keybindings/ScrollContainer/Controls/PlayerSelect/OptionButton.get_selected_id() + 1)
		var input: String = str(action)
		var path: String = "TabContainer/Keybindings/ScrollContainer/Controls/HBoxCont_" + input + "/Button"
		var current_action_array: Array = InputMap.get_action_list(str(action + selected_player))
		var current_action: InputEvent
		var string: String
		
		if !current_action_array.empty():
			current_action = current_action_array[0]
			string= current_action.as_text()

		if string.empty():
			get_node(path).text = "No button"
		else:
			get_node(path).text = string


func _mark_button(string: String):
	var selected_player: String = str($TabContainer/Keybindings/ScrollContainer/Controls/PlayerSelect/OptionButton.get_selected_id() + 1)
	can_change_key = true
	action_string = string + selected_player


func _change_key(new_key: InputEvent):
	# Delete previous control
	if !InputMap.get_action_list(action_string).empty():
		InputMap.action_erase_event(action_string, InputMap.get_action_list(action_string)[0])
	
	# Delete key if it's used somewhere else
	for action in ACTIONS:
		if InputMap.action_has_event(action, new_key):
			InputMap.action_erase_event(action, new_key)
	
	InputMap.action_add_event(action_string, new_key)


func 


func _on_MainMenu_show_options():
	visible = true


func _on_BackButton_pressed():
	visible = false


func _on_FullscreenCheckBox_toggled(button_pressed):
	OS.window_fullscreen = button_pressed


func _on_Borderless_toggled(button_pressed):
	OS.window_borderless = button_pressed


func _on_OptionButton_item_selected(index):
	_set_keys()


func _on_change_key_move_right():
	_mark_button("move_right_")


func _on_change_key_move_left():
	_mark_button("move_left_")


func _on_change_key_jump():
	_mark_button("jump_")


func _on_change_key_cast():
	_mark_button("cast_")


func _on_change_key_aim_right():
	_mark_button("aim_right_")


func _on_change_key_aim_left():
	_mark_button("aim_left_")


func _on_change_key_aim_up():
	_mark_button("aim_up_")


func _on_change_key_aim_down():
	_mark_button("aim_down_")


func _on_ControllerCheckBox_toggled(button_pressed):
	controller_checked = button_pressed
