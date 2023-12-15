extends VehicleBody3D


@onready var steering_wheel = $Interior/SteeringWheelBase/Node3D/steering_wheel



@export var STEER_SPEED = 1.5
@export var STEER_LIMIT = 0.8
var steer_target = 0
@export var engine_force_value = 40
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

@onready var left_camera = $Hud/Container/LeftMirror/Subviewport/Node3D
@onready var right_camera = $Hud/Container/RightMirror/Subviewport/Node3D
@onready var middle_camera = $Hud/Container/MiddleMirror/Subviewport/Node3D
@onready var middle_mirror_marker = $MiddleMirrorMarker
@onready var right_mirror_marker = $RightMirrorMarker
@onready var left_mirror_marker = $LeftMirrorMarker

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
	traction(speed)
	speed_text.text=str(round(speed*3.8))+"  KMPH"

	var fwd_mps = transform.basis.x.x
	steer_target = Input.get_action_strength("ui_left") - Input.get_action_strength("ui_right")
	steer_target *= STEER_LIMIT
	if Input.is_action_pressed("ui_up"):
	# Increase engine force at low speeds to make the initial acceleration faster.

		if speed < 20 and speed != 0:
			engine_force = clamp(engine_force_value * 3 / speed, 0, 300)
		else:
			engine_force = engine_force_value
	else:
		engine_force = 0
	if Input.is_action_pressed("ui_down"):
		# Increase engine force at low speeds to make the initial acceleration faster.
		if fwd_mps >= -1:
			if speed < 30 and speed != 0:
				engine_force = -clamp(engine_force_value * 10 / speed, 0, 300)
			else:
				engine_force = -engine_force_value
		else:
			brake = 1
	else:
		brake = 0.0
		
	if Input.is_action_pressed("ui_select"):
		brake=3
		$right_rear.wheel_friction_slip=0.8
		$left_rear.wheel_friction_slip=0.8
	else:
		$right_rear.wheel_friction_slip=1.4
		$left_rear.wheel_friction_slip=1.4
	steering = move_toward(steering, steer_target, STEER_SPEED * delta)
	
	
	steering_wheel.rotation.z = move_toward(steering_wheel.rotation.z,-steer_target*deg_to_rad(360+180),steering_wheel_speed*delta) 



func traction(speed):
	apply_central_force(Vector3.DOWN*speed)




