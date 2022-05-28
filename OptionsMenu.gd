extends Control

enum ACTIONS{move_right_, move_left_, jump_, cast_, aim_up_, aim_down_, aim_left_, aim_right_}

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
