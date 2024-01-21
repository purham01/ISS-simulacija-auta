extends Area3D

@export var new_max_speed = 50.0
@export var new_engine_force_value = 80.0

func _on_body_entered(body):
	if body.is_in_group("Car"):
		body.max_speed = new_max_speed
		body.engine_force_value = new_engine_force_value
		print("New max speed: "+ str(body.max_speed))
		print("New engine force: "+str(body.engine_force_value))
