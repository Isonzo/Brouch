extends Control


func _on_MainMenu_show_options():
	visible = true


func _on_BackButton_pressed():
	visible = false


func _on_FullscreenCheckBox_toggled(button_pressed):
	OS.window_fullscreen = button_pressed


func _on_Borderless_toggled(button_pressed):
	OS.window_borderless = button_pressed
