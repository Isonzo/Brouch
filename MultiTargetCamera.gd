extends Camera2D

export var move_speed: float = 0.5
export var zoom_speed: float = 0.05
export var min_zoom: float = 0.5
export var max_zoom: float = 1
export var margin: Vector2 = Vector2(50, 25)

var targets = []

onready var screen_size: Rect2 = get_viewport_rect()

func add_target(t: KinematicBody2D):
	if not t in targets:
		targets.append(t)

func remove_target(t: KinematicBody2D):
	if t in targets:
		targets.remove(t)

func _process(delta):
	if !targets:
		return
	
	var center: Vector2 = Vector2.ZERO
	for target in targets:
		center += target.position
	center /= targets.size()
	position = lerp(position, center, move_speed)
	
	var view: Rect2 = Rect2(position, Vector2.ONE)
	for target in targets:
		view = view.expand(target.position)
	view = view.grow_individual(margin.x, margin.y, margin.x, margin.y)
	
	var longest_side = max(view.size.x, view.size.y)
	var zoom_level
	zoom_level = clamp(view.size.x / screen_size.size.x, min_zoom, max_zoom)
	
	zoom = lerp(zoom, Vector2.ONE * zoom_level, zoom_speed)
