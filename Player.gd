extends KinematicBody2D

enum {
	IDLE,
	MOVING,
	JUMPING,
	FALLING,
	CASTING
}

const SPEED = 80
const GRAVITY = 1000
const FRICTION = 0.7
const JUMP_POWER = -200
const GLIDE_EFFICIENCY = 0.6
var velocity = Vector2.ZERO
var _state :int = IDLE
var long_time_ground = true
var previous_y: float
var cast_time = 1

export var id: int = 1


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
			$AnimationPlayer.play("cast")
			$CastTime.start(cast_time)
			
	face_direction(dir)
		
	squash_and_stretch()

	move_and_slide(velocity, Vector2.UP)


	$Label.text = str(_state)

func get_dir() -> int:
	var dir: int = 0
	if Input.is_action_pressed("move_right_%d" % id):
		dir += 1
	if Input.is_action_pressed("move_left_%d" % id):
		dir -= 1
	
	return dir

func get_movement(dir) -> void:
	velocity.x = lerp(velocity.x, SPEED * dir, FRICTION)

func apply_gravity(delta) -> void:
	if Input.is_action_pressed("jump_%d" % id) and not is_on_ceiling():
		velocity.y += GRAVITY * GLIDE_EFFICIENCY * delta
	else:
		velocity.y += GRAVITY * delta
		if velocity.y < 0:
			velocity.y = 0

func face_direction(dir: int) ->void:
	if dir == -1:
		$Sprite.flip_h = true
	elif dir == 1:
		$Sprite.flip_h = false

func squash_and_stretch() -> void:
	if not is_on_floor():
		$Sprite.scale.y = range_lerp(abs(velocity.y), 0, abs(JUMP_POWER), 1, 1.6)
		$Sprite.scale.x = range_lerp(abs(velocity.y), 0, abs(JUMP_POWER), 1, 0.6)
	elif is_on_floor() and not long_time_ground:
		long_time_ground = true
		$Sprite.scale.y = range_lerp(abs(previous_y), 0, abs(1700), 0.8, 0.5)
		$Sprite.scale.x = range_lerp(abs(previous_y), 0, abs(1700), 1.2, 2.0)
	else:
		$Sprite.scale.x = lerp($Sprite.scale.x, 1, 0.2)
		$Sprite.scale.y = lerp($Sprite.scale.y, 1, 0.2)
	
	previous_y = velocity.y


func _on_CastTime_timeout():
	_state = IDLE
