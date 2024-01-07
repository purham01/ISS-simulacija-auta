extends VehicleBody3D


@export var engine_force_value = 200
@export var steering_wheel_speed = 10
@export var STEER_SPEED = 1.5
@export var STEER_LIMIT = 0.8

@onready var nav = $NavigationAgent3D
@onready var ray_cast_3d = $RayCast3D
@export var target : Node3D
@export var path_follow : PathFollow3D

var can_move = false

func _ready():
	call_deferred("actor_setup")

func actor_setup():
	await get_tree().physics_frame
	can_move = true
	


func _physics_process(delta):
	if can_move:
		var direction = Vector3()
		
		if target != null:
			#print("Target found")
			nav.target_position = target.global_position
		
			var destination = nav.get_next_path_position() 

			var car_vector2 = Vector2(global_position.x,global_position.z)
			var destionation_vector2 = Vector2(destination.x,destination.z)
			
			print(global_position.distance_to(target.global_position))
			
			follow_target(destination)
			if global_position.distance_to(target.global_position)<10:
				path_follow.progress_ratio+=0.001

			
			#if destionation_vector2.distance_to(car_vector2)<5 or destionation_vector2.distance_to(car_vector2) > 10:
				#engine_force = 0
				#brake = 6
			
			if ray_cast_3d.is_colliding():
				engine_force = 0
				brake = 6
			else:
				engine_force = engine_force_value
				brake=0
			
			var speed = linear_velocity.length()
			traction(speed)

func follow_target(steering_target):
	var fwd = self.linear_velocity.normalized()
	var target_vector = (steering_target - global_position)
	#var distance = target_vector.length()
	steering = fwd.cross(target_vector.normalized()).y
	#print("steering: " + str(steering))

func traction(speed):
	apply_central_force(Vector3.DOWN*speed)

