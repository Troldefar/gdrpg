extends KinematicBody2D

const FRICTION = 300
const ACCELERATION = 100
const ROLL_SPEED = 100
const MAX_SPEED = 200

enum { MOVE, ROLL, ATTACK }

var state = MOVE
var velocity = Vector2.ZERO
var roll_vector = Vector2.DOWN

onready var animationPlayer = $AnimationPlayer
onready var animationTree   = $AnimationTree
onready var animationState = animationTree.get('parameters/playback')

# Delta = Time last frame took to process

func _ready():
	animationTree.active = true

func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
		ROLL:
			roll_state()
		ATTACK:
			attack_state()

func roll_animation_finished():
	state = MOVE
	velocity = Vector2.ZERO

func roll_state():
	velocity = roll_vector * ROLL_SPEED
	animationState.travel("Roll")
	move()

func attack_state():
	velocity = Vector2.ZERO
	animationState.travel("Attack")

func attack_animation_finished():
	state = MOVE

func move():
	velocity = move_and_slide(velocity)

func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()

	if input_vector != Vector2.ZERO:
		roll_vector = input_vector
		animationTree.set('parameters/Idle/blend_position', input_vector)
		animationTree.set('parameters/Run/blend_position', input_vector)
		animationTree.set('parameters/Attack/blend_position', input_vector)
		animationTree.set('parameters/Roll/blend_position', input_vector)
		animationState.travel("Run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		
	# velocity * delta to make it relative to our framerate
	move()
	
	if Input.is_action_just_pressed("roll"):
		state = ROLL
	
	if Input.is_action_just_pressed("attack"):
		state = ATTACK
