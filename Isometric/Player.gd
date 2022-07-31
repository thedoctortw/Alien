extends KinematicBody2D

onready var _animated_sprite = $AnimatedSprite
const MOTION_SPEED = 160 # Pixels/second.
var jumped = false

signal jumped
signal evolve

var right_move = "fh_right_walk"
var left_move = "fh_left_walk"
var forward_move = "fh_forward_walk"
var backward_move = "fh_backward_walk"

func _physics_process(_delta):
	var motion = Vector2()
	motion.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	motion.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	motion.y /= 2
	motion = motion.normalized() * MOTION_SPEED
	
		#Player Actions
	if Input.is_action_pressed("facehugger_jump"):
		_on_Player_jumped(motion)
		
	#warning-ignore:return_value_discarded
	move_and_slide(motion)
		

func _process(_delta):
	if Input.is_action_pressed("ui_right"):
		_animated_sprite.play(right_move)
	elif Input.is_action_pressed("ui_left"):
		_animated_sprite.play(left_move)
	elif Input.is_action_pressed("ui_up"):
		_animated_sprite.play(forward_move)
	elif Input.is_action_pressed("ui_down"):
		_animated_sprite.play(backward_move)
	else:
		_animated_sprite.stop()

#JUMP LOGIC
#to be improved
func _on_Player_jumped(motion):
	evolve()
	if(!jumped):
		$AnimatedSprite/JumpTimer.start()
		jumped = true;
		
		self.set_position(Vector2(self.get_position().x + motion.x * 1.2,self.get_position().y + motion.y))
		motion.y -= 10


func _on_JumpTimer_timeout():
	jumped = false;

#METAMORPHOSIS
func evolve():
	emit_signal("evolve")

func _on_Player_evolve():
	right_move = "cb_right_walk"
	left_move = "cb_left_walk"
	forward_move = "cb_forward_walk"
	backward_move = "cb_backward_walk"
