extends RigidBody2D

onready var sprite = get_node("Sprite")
onready var rear_left_light = get_node("RearLeft_Light")
onready var rear_right_light = get_node("RearRight_Light")

const ACCELERATION = 200
const BRAKING = 400
const REVERSE = 90
const STEERING = 75

var steering_com = 0.0
var force_com = 0.0


func _ready():
	set_process(true)
	set_physics_process(true)
	
	pass


func _process(delta):
	
	var forward_vector = Vector2(1, 0).rotated(rotation)
	var dot_product = forward_vector.dot(linear_velocity)
	var is_moving_forwards = true
	if(!is_nan(dot_product) && dot_product < 0):
		is_moving_forwards = false
	
	var is_braking = false
	var is_reversing = false
	
	# acceleration
	force_com = 0.0
	if(Input.is_action_pressed("car_accelerate")):
		# check direction, if we are going backwards this is actually brake function
		if(is_moving_forwards):
			force_com = ACCELERATION
			is_braking = false
		else:
			force_com = BRAKING
			is_braking = true
	
	# brake
	if(Input.is_action_pressed("car_brake")):
		# check direction, if we are going backwards this is actually accelerate function
		if(is_moving_forwards):
			force_com = -BRAKING
			is_braking = true
		else:
			force_com = -REVERSE
			is_braking = false
			is_reversing = true
	
	# steering
	steering_com = 0.0
	if(linear_velocity.length() > 0):
		if(Input.is_action_pressed("car_steer_left")):
			if(is_moving_forwards):
				steering_com = -STEERING
			else:
				steering_com = STEERING
		
		if(Input.is_action_pressed("car_steer_right")):
			if(is_moving_forwards):
				steering_com = STEERING
			else:
				steering_com = -STEERING
	
	
	# brake lights
	rear_left_light.color = Color(0.83, 0, 0, 1)
	if(is_braking):
		rear_left_light.energy = 3
		rear_right_light.energy = 3
	else:
		rear_left_light.energy = 1
		rear_right_light.energy = 1
	
	# reverse light
	if(is_reversing):
		rear_left_light.color = Color(1, 1, 1, 1)
		rear_left_light.energy = 3
	
	pass


func _physics_process(delta):
	
	# steering
	#global_rotation += deg2rad(steering_com) * delta
	angular_velocity = steering_com * delta
	
	# accelerate
	apply_impulse(Vector2(), Vector2(force_com * delta, 0).rotated(rotation))
	
	# TODO: clamp velocity to max speed

func _integrate_forces(state):
	kill_orthogonal_velocity(0.0)


func kill_orthogonal_velocity(drift):
	
	var bodyForward = Vector2(1, 0).rotated(rotation)
	var bodyRight = Vector2(1, 0).rotated(rotation + deg2rad(90))
	var forwardVelocity = bodyForward * (linear_velocity.dot(bodyForward))
	var rightVelocity = bodyRight * (linear_velocity.dot(bodyRight))
	
	linear_velocity = forwardVelocity + (rightVelocity * drift)
