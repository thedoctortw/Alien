extends CharacterBody2D
@onready var _animated_sprite = $AnimatedSprite2D
const MOTION_SPEED = 160 # Pixels/second.

func _physics_process(_delta):
	var motion = Vector2()
	motion.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	motion.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	motion.y /= 2
	motion = motion.normalized() * MOTION_SPEED
	#warning-ignore:return_value_discarded
	set_velocity(motion)
	move_and_slide()

func _process(_delta):
	if Input.is_action_pressed("ui_right"):
		_animated_sprite.play("right_walk")
	elif Input.is_action_pressed("ui_left"):
		_animated_sprite.play("left_walk")
	elif Input.is_action_pressed("ui_up"):
		_animated_sprite.play("forward_walk")
	elif Input.is_action_pressed("ui_down"):
		_animated_sprite.play("backward_walk")
	else:
		_animated_sprite.stop()
