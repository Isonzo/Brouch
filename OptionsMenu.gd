extends Control

enum ACTIONS{move_right_, move_left_, jump_, cast_}

func _ready():
	_set_keys()

func _set_keys():
	for action in ACTIONS:
		var input: String = str(action)
		var path: String = "TabContainer/Keybindings/ScrollContainer/Controls/HBoxCont_" + input + "/Button"
		var current_action: InputEvent = InputMap.get_action_list(str(action + "1"))[0]
		var string: String = current_action.as_text()
		
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
