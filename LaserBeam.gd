extends Node2D

const MAX_LENGTH = 500
onready var beam: Sprite = $Beam
onready var end: Position2D = $End
onready var raycast: RayCast2D = $RayCast2D
export var emitting: bool = false
export var laser_visible: bool = false
export var raycast_enabled: bool = false

func _physics_process(delta) -> void:
	$End/Particles2D.emitting = emitting
	beam.visible = laser_visible
	$Begin.visible = laser_visible
	raycast.enabled = raycast_enabled
	var mouse_position = get_local_mouse_position()
	var max_cast_to = mouse_position.normalized() * MAX_LENGTH
	raycast.cast_to = max_cast_to
		
	if raycast.is_colliding():
		end.global_position = raycast.get_collision_point()
		if raycast.get_collider().has_method("die"):
			raycast.get_collider().die()
	else:
		end.global_position = raycast.cast_to
		
	beam.rotation = raycast.cast_to.angle()
		
	beam.region_rect.end.x = end.position.length()
