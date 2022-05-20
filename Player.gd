extends KinematicBody2D

enum {
	IDLE,
	MOVING,
	JUMPING,
	FALLING,
	CASTING,
	DEAD
}


const SPEED: int = 80
const GRAVITY: int = 1000
const FRICTION: float = 0.7
const DEATH_SLIDE: int = 100
const DEATH_SLIDE_FACTOR: float = 0.05
const JUMP_POWER: int = -200
const GLIDE_EFFICIENCY: float = 0.6
const AIM_DISTANCE: int = 12
var velocity: Vector2 = Vector2.ZERO
var _state :int = IDLE
var long_time_ground = true
var previous_y: float
var cast_time: int = 1
var casting: bool = false
var aim_vector: Vector2 = Vector2.ZERO
var dead: bool = false

onready var aim_reticle: Sprite = $AimReticle
onready var texture: Texture = load("res://assets/witchsheet%d.png" % id)
onready var run_dust := load("res://RunDust.tscn")
onready var land_dust := load("res://LandDust.tscn")
export var id: int = 1
export var sprite_path: String


func _ready() -> void:
	set_collision_layer_bit(id - 1, true)
	$LaserBeam/RayCast2D.set_collision_mask_bit(id - 1, false)
	$Sprite.texture = texture


func _physics_process(delta: float) -> void:
	var dir: int = 0
	match _state:
		IDLE:
			$AnimationPlayer.play("idle")
			
			velocity.y = 10
			
			if not is_on_floor():
				_state = FALLING
			elif Input.is_action_pressed("jump_%d" % id):
				_state = JUMPING
			elif Input.is_action_pressed("cast_%d" % id) and aim_reticle.visible:
				_state = CASTING
			elif Input.is_action_pressed("move_right_%d" % id) or Input.is_action_pressed("move_left_%d" % id):
				_state = MOVING
			
			velocity.x = lerp(velocity.x, 0, FRICTION)
			
		MOVING:
			$AnimationPlayer.play("walk")
			
			if not is_on_floor():
				_state = FALLING
			velocity.y = 10
			
			if Input.is_action_pressed("jump_%d" % id):
				_state = JUMPING
			elif Input.is_action_pressed("cast_%d" % id) and aim_reticle.visible:
				_state = CASTING
			dir = get_dir()
			get_movement(dir)
			if dir == 0:
				_state = IDLE

		JUMPING:
			long_time_ground = false
			$AnimationPlayer.play("jump")
			if is_on_floor():
				velocity.y = JUMP_POWER
			dir = get_dir()
			get_movement(dir)
			apply_gravity(delta)
			if (velocity.y >= 0):
				_state = FALLING
			pass

		FALLING:
			apply_gravity(delta)
			dir = get_dir()
			get_movement(dir)
			if is_on_floor() and dir == 0:
				_state = IDLE
			elif is_on_floor():
				_state = MOVING
		
		CASTING:
			velocity.x = lerp(velocity.x, 0, FRICTION)
			if not casting:
				var aim_dir: Vector2 = aim_vector
				dir = round(aim_dir.x)	
				$AnimationPlayer.play("cast")
				$CastTime.start(-1)
				casting = true
		
		DEAD:
			if not is_on_floor():
				apply_gravity(delta)
			velocity.x = lerp(velocity.x, 0, DEATH_SLIDE_FACTOR)
	if not _state == DEAD:		
		face_direction(dir)
		
		if (_state != CASTING):
			show_aim()
			
	squash_and_stretch()

	move_and_slide(velocity, Vector2.UP)
	
	free_emitters()


	$Label.text = str(_state)

func get_dir() -> int:
	var dir: int = 0
	if Input.is_action_pressed("move_right_%d" % id):
		dir += 1
	if Input.is_action_pressed("move_left_%d" % id):
		dir -= 1
	
	return dir

func get_movement(dir: int) -> void:
	velocity.x = lerp(velocity.x, SPEED * dir, FRICTION)

func apply_gravity(delta: float) -> void:
	if Input.is_action_pressed("jump_%d" % id) and not is_on_ceiling():
		velocity.y += GRAVITY * GLIDE_EFFICIENCY * delta
	else:
		velocity.y += GRAVITY * delta
		if velocity.y < 0:
			velocity.y = 0

func face_direction(dir: int) ->void:
	if aim_reticle.visible and aim_reticle.position.x > 0:
		$Sprite.flip_h = false
		$LaserBeam.position.x = abs($LaserBeam.position.x)
		return
	elif aim_reticle.visible and aim_reticle.position.x < 0:
		$Sprite.flip_h = true
		$LaserBeam.position.x = abs($LaserBeam.position.x) * -1
		return
	if dir == -1:
		$Sprite.flip_h = true
		$LaserBeam.position.x = abs($LaserBeam.position.x) * -1
	elif dir == 1:
		$Sprite.flip_h = false
		$LaserBeam.position.x = abs($LaserBeam.position.x)
		
func squash_and_stretch() -> void:
	if not is_on_floor():
		$Sprite.scale.y = range_lerp(abs(velocity.y), 0, abs(JUMP_POWER), 1, 1.6)
		$Sprite.scale.x = range_lerp(abs(velocity.y), 0, abs(JUMP_POWER), 1, 0.6)
	elif is_on_floor() and not long_time_ground:
		long_time_ground = true
		$Sprite.scale.y = range_lerp(abs(previous_y), 0, abs(1700), 0.8, 0.5)
		$Sprite.scale.x = range_lerp(abs(previous_y), 0, abs(1700), 1.2, 2.0)
		
		if previous_y > 260:
			spawn_land_dust()
	else:
		$Sprite.scale.x = lerp($Sprite.scale.x, 1, 0.2)
		$Sprite.scale.y = lerp($Sprite.scale.y, 1, 0.2)
	
	previous_y = velocity.y

func die(raycast_position: Vector2):
	_state = DEAD
	aim_reticle.visible = false
	$AnimationPlayer.play("die")
	set_collision_layer_bit(id - 1, false)
	if global_position.x < raycast_position.x:
		velocity.x = -DEATH_SLIDE
	else:
		velocity.x = DEATH_SLIDE

func show_aim() -> void:
	aim_vector.x = Input.get_action_strength("aim_right_%d" % id) - Input.get_action_strength("aim_left_%d" % id)
	aim_vector.y = Input.get_action_strength("aim_down_%d" %id) - Input.get_action_strength("aim_up_%d" % id)
	
	aim_vector = aim_vector.normalized()
	
	aim_reticle.visible = (aim_vector != Vector2.ZERO)
	
	aim_reticle.position = aim_vector * AIM_DISTANCE
	aim_reticle.position.y -= 1
	
	if abs(aim_reticle.position.x) < abs($LaserBeam.position.x):
		aim_reticle.position.x = $LaserBeam.position.x

func _on_CastTime_timeout():
	if not _state == DEAD:
		_state = IDLE
	casting = false


func spawn_run_dust() -> void:
	var _run_dust_instance = run_dust.instance()
	_run_dust_instance.emitting = true
	$Particles.add_child(_run_dust_instance)

func spawn_jump_dust() -> void:
	var _run_dust_instance = run_dust.instance()
	_run_dust_instance.lifetime = 5
	_run_dust_instance.explosiveness = 0.95
	_run_dust_instance.emitting = true
	$Particles.add_child(_run_dust_instance)

func spawn_land_dust() -> void:
	var _land_dust_instance = land_dust.instance()
	_land_dust_instance.emitting = true
	$Particles.add_child(_land_dust_instance)


func free_emitters() ->void:
	for emitter in $Particles.get_children():
		if not emitter.emitting:
			emitter.queue_free()
