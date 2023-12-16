extends VehicleBody3D


@onready var steering_wheel = $Interior/SteeringWheelBase/Node3D/steering_wheel



@export var STEER_SPEED = 1.5
@export var STEER_LIMIT = 0.8
var steer_target = 0
@export var engine_force_value = 400
@export var steering_wheel_speed = 10

@export var SENSITIVITY = 0.015
@onready var look = $look
@onready var head = $look/headCamera
@onready var twist_pivot = $TwistPivot
@onready var pitch_pivot = $TwistPivot/PitchPivot


@onready var rotating_camera = $TwistPivot/PitchPivot/rotatingCamera
@export var rotating_camera_limit_bottom := -40
@export var rotating_camera_limit_top := 60
@onready var floating_camera = $look/floatingCamera
@onready var speed_text = %speed
@onready var gear_text = %gear

@onready var left_camera = $Hud/Container/LeftMirror/Subviewport/Node3D
@onready var right_camera = $Hud/Container/RightMirror/Subviewport/Node3D
@onready var middle_camera = $Hud/Container/MiddleMirror/Subviewport/Node3D
@onready var middle_mirror_marker = $MiddleMirrorMarker
@onready var right_mirror_marker = $RightMirrorMarker
@onready var left_mirror_marker = $LeftMirrorMarker

var gear = 1

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	

func _input(event):
	
	if event.is_action_pressed("change_view"):
		if rotating_camera.current == true:
			head.current = true
		elif head.current == true:
			floating_camera.current = true
		elif floating_camera.current == true:
			rotating_camera.current = true
	
	if head.current == true:
		if event is InputEventMouseMotion:
			if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
				look.rotate_y(-event.relative.x * SENSITIVITY)
				head.rotate_x(-event.relative.y * SENSITIVITY)
				head.rotation.x = clamp(head.rotation.x, deg_to_rad(-40), deg_to_rad(60))

	if rotating_camera.current == true:
		if event is InputEventMouseMotion:
			if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
				twist_pivot.rotate_y(-event.relative.x * SENSITIVITY*0.5)
				pitch_pivot.rotate_x(event.relative.y * SENSITIVITY*0.5)
				pitch_pivot.rotation.x = clamp(pitch_pivot.rotation.x, deg_to_rad(rotating_camera_limit_bottom), deg_to_rad(rotating_camera_limit_top))
	
	
	#ako stisnemo escape možemo micat miš okolo, ak stisnemo opet na ekran se vrati
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
	left_camera.global_transform = left_mirror_marker.global_transform
	right_camera.global_transform = right_mirror_marker.global_transform
	middle_camera.global_transform= middle_mirror_marker.global_transform
	
	


func _physics_process(delta):
	var speed = linear_velocity.length()*Engine.get_frames_per_second()*delta
	var kmph = speed*3.8
	traction(speed)
	speed_text.text=str(round(kmph))+"  KMPH"
	gear_text.text= str(gear)


	steer_target = Input.get_action_strength("ui_left") - Input.get_action_strength("ui_right")
	steer_target *= STEER_LIMIT
	if Input.is_action_pressed("ui_up"):
	# Increase engine force at low speeds to make the initial acceleration faster.

		if (gear == 1):
			if (kmph >= 25):
				engine_force = 0
			else:
				engine_force = engine_force_value
		elif (gear == 2):
			if (kmph >= 40):
				engine_force = 0
			else:
				engine_force = engine_force_value * 0.8
		elif (gear == 3):
			if (kmph >= 70):
				engine_force = 0
			else:
				engine_force = engine_force_value * 0.6
		elif (gear == 4):
			if (kmph >= 105):
				engine_force = 0
			else:
				engine_force = engine_force_value * 0.5
		elif (gear == 5):
			engine_force = engine_force_value * 0.4	
	
	elif Input.is_action_pressed("ui_down"):
		engine_force = -engine_force_value*0.5
		
		
	else:
		engine_force = 0
	
	if Input.is_action_just_pressed("gear_up"):
		if (gear < 5):
			gear += 1
		
	if Input.is_action_just_pressed("gear_down"):
		if (gear > 1):
			gear -= 1
	
	if Input.is_action_pressed("ui_select"):
		
		$right_rear.wheel_friction_slip=0.8
		$left_rear.wheel_friction_slip=0.8
	else:
		$right_rear.wheel_friction_slip=1.4
		$left_rear.wheel_friction_slip=1.4
	
	
	steering = move_toward(steering, steer_target, STEER_SPEED * delta)
	
	
	steering_wheel.rotation.z = move_toward(steering_wheel.rotation.z,-steer_target*deg_to_rad(360+180),steering_wheel_speed*delta) 



func traction(speed):
	apply_central_force(Vector3.DOWN*speed)




