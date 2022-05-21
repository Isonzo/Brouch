extends Node2D

const MAX_LENGTH = 2000
onready var beam: Sprite = $Beam
onready var end: Position2D = $End
onready var raycast: RayCast2D = $RayCast2D
onready var smoke:=  load("res://smoke_effect.tscn")
export var emitting: bool = false
export var laser_visible: bool = false
export var raycast_enabled: bool = false
var emitted: bool = false

func _physics_process(delta) -> void:
	beam.visible = laser_visible
	$Begin.visible = laser_visible
	raycast.enabled = raycast_enabled
	var aim_dir = get_parent().aim_reticle.global_position - global_position
	aim_dir = aim_dir.normalized()
	var max_cast_to = aim_dir * MAX_LENGTH
	raycast.cast_to = max_cast_to
		
	if raycast.is_colliding():
		end.global_position = raycast.get_collision_point()
		if not emitted:
			add_emitter()
		if raycast.get_collider().has_method("die"):
			raycast.get_collider().die(raycast.global_position)
	else:
		emitted = false
		
	beam.rotation = raycast.cast_to.angle()
		
	beam.region_rect.end.x = end.position.length()
	
	free_emitters()

func add_emitter() ->void:
	var smoke_instance = smoke.instance()
	smoke_instance.emitting = true
	end.add_child(smoke_instance)
	emitted = true

func free_emitters() ->void:
	for emitter in $End.get_children():
		if not emitter.emitting:
			emitter.queue_free()
