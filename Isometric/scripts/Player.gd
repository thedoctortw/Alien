extends CharacterBody2D

@onready var _animated_sprite = $AnimatedSprite2D
const MOTION_SPEED = 160 # Pixels/second.

const FACEHUGGER_ID = "fh"
const CHESTBURSTER_ID = "cb"
const XENOMORPH_ID = "xn"

const direction_left = "left"
const direction_right = "right"
const direction_backward = "backward"
const direction_forward = "forward"

var jumped = false

signal jumpedSignal
signal attackSignal
signal evolveSignal
signal layEggSignal

# Alien evolve steps -> fh, cb, xn, qn
var currentLifeCycle = FACEHUGGER_ID
var currentDirection = direction_forward;

var right_move = currentLifeCycle + "_" + direction_right + "_walk"
var left_move = currentLifeCycle + "_" + direction_left + "_walk"
var forward_move = currentLifeCycle + "_" + direction_forward + "_walk"
var backward_move = currentLifeCycle + "_" + direction_backward + "_walk"

var right_attack = currentLifeCycle + "_" + direction_right + "_attack"
var left_attack = currentLifeCycle + "_" + direction_left + "_attack"
var forward_attack = currentLifeCycle + "_" + direction_forward + "_attack"
var backward_attack = currentLifeCycle + "_" + direction_backward + "_attack"

func _physics_process(_delta):
	var motion = Vector2()
	motion.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	motion.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	motion.y /= 2

	motion = motion.normalized() * MOTION_SPEED
	
		#Player Actions
	if Input.is_action_pressed("facehugger_jump"):
		motion = _on_Player_jumped(motion) * MOTION_SPEED / 10
	elif Input.is_action_just_pressed("lay_egg"):
		_on_lay_egg_signal(currentLifeCycle, _animated_sprite.global_position)

	#warning-ignore:return_value_discarded
		
	set_velocity(motion)
	move_and_slide()

func _process(_delta):
	if Input.is_action_pressed("ui_right"):
		currentDirection = direction_right
		_animated_sprite.play(right_move)
	elif Input.is_action_pressed("ui_left"):
		currentDirection = direction_left
		_animated_sprite.play(left_move)
	elif Input.is_action_pressed("ui_up"):
		currentDirection = direction_forward
		_animated_sprite.play(forward_move)
	elif Input.is_action_pressed("ui_down"):
		currentDirection = direction_backward
		_animated_sprite.play(backward_move)
	elif Input.is_action_just_pressed("attack"):
		emit_signal("attackSignal")
		_animated_sprite.play(getAttackAnimation(currentLifeCycle, currentDirection))
	elif _animated_sprite.get_animation() != currentLifeCycle + "_" + currentDirection + "_attack":
		_animated_sprite.stop()
	

#JUMP LOGIC
#to be improved
func _on_Player_jumped(motion):
	if(!jumped):
		$AnimatedSprite2D/JumpTimer.start()
		jumped = true;
		evolve()
		#self.set_position(Vector2(self.get_position().x + motion.x * 1.2,self.get_position().y + motion.y))
		if Input.is_action_pressed("ui_right"):
			motion.x += 2
			motion.y -= 2
		elif Input.is_action_pressed("ui_left"):
			motion.x -= 2
			motion.y += 2
		elif Input.is_action_pressed("ui_up"):
			motion.y -= 2
			motion.x += 2
		elif Input.is_action_pressed("ui_down"):
			motion.y += 2
			motion.x -= 2

	return motion


func _on_JumpTimer_timeout():
	jumped = false;
	
# ATTACK LOGIC
func _on_Player_attack():
	_animated_sprite.play(currentLifeCycle + "_" + currentDirection + "_attack")

#METAMORPHOSIS
func evolve():
	emit_signal("evolveSignal")

func _on_evolve_signal():
	var nextLifeCycle = currentLifeCycle
	
	if currentLifeCycle == FACEHUGGER_ID:
		nextLifeCycle = CHESTBURSTER_ID
	elif nextLifeCycle == CHESTBURSTER_ID:
		nextLifeCycle = XENOMORPH_ID
	#elif nextLifeCycle == "xn":
		#nextLifeCycle = "qn"
	
	currentLifeCycle = nextLifeCycle

	right_move = nextLifeCycle + "_right_walk"
	left_move = nextLifeCycle + "_left_walk"
	forward_move = nextLifeCycle + "_forward_walk"
	backward_move = nextLifeCycle + "_backward_walk"
	
func getAttackAnimation (currentLifeCycle, currentDirection):
	return currentLifeCycle + "_" + currentDirection + "_attack"
	
func layEgg():
	emit_signal("layEggSignal")

@onready var egg = preload("res://scenes//Egg.tscn")
func _on_lay_egg_signal (currentLifeCycle, position:Vector2, scene = self):
	print("entered")
	if (currentLifeCycle == XENOMORPH_ID):
		var eggInstance = egg.instantiate() # creates an instance of the player, obviously
		eggInstance.global_position = position
		print (scene.get_tree().root)
		add_sibling(eggInstance)
