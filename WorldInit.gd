extends Node

onready var players: Array = $Players.get_children()
func _ready():
	for player in players:
		$Camera2D.add_target(player)
