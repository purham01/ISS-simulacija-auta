extends Camera3D


@export var target_distance = 5
@export var target_height = 2
@export var speed:=20.0
var follow_this = null
var last_lookat
@export var SENSITIVITY = 0.015

@onready var twist_pivot = $"../.."
@onready var pitch_pivot = $".."
@onready var reset_camera_timer = $"../ResetCameraTimer"
var mouse_input = false

func _ready():
	follow_this = get_parent()
	last_lookat = follow_this.global_transform.origin
#
func _input(event):
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			mouse_input = true
			reset_camera_timer.start()
			twist_pivot.rotate_y(-event.relative.x * SENSITIVITY*0.5)
			pitch_pivot.rotate_x(event.relative.y * SENSITIVITY*0.5)
			pitch_pivot.rotation.x = clamp(pitch_pivot.rotation.x, deg_to_rad(-40), deg_to_rad(60))
#

func _physics_process(delta):
	if !mouse_input:
		var delta_v = global_transform.origin - follow_this.global_transform.origin
		var target_pos = global_transform.origin
		
		# ignore y
		delta_v.y = 0.0
		
		if (delta_v.length() > target_distance):
			delta_v = delta_v.normalized() * target_distance
			delta_v.y = target_height
			target_pos = follow_this.global_transform.origin + delta_v
		else:
			target_pos.y = follow_this.global_transform.origin.y + target_height
		
		global_transform.origin = global_transform.origin.lerp(target_pos, delta * speed)
		
		last_lookat = last_lookat.lerp(follow_this.global_transform.origin, delta * speed)
		
		
		look_at(last_lookat, Vector3.UP)


func _on_reset_camera_timer_timeout():
	mouse_input= false
	twist_pivot.rotate_y(twist_pivot.rotation.y)
	pitch_pivot.rotate_x(pitch_pivot.rotation.x)
