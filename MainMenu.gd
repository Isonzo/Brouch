extends Control

signal show_options

func _on_QuitButton_pressed():
	get_tree().quit()


func _on_OptionsButton_pressed():
	emit_signal("show_options")


func _on_PlayButton_pressed():
	get_tree().change_scene("res://TestWorld.tscn")
