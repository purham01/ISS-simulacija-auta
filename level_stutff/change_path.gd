extends Area3D

@export var new_target : Node3D
@export var new_path_follow : PathFollow3D

func _on_body_entered(body):
	if body.is_in_group("Car"):
		body.target = new_target
		body.path_follow = new_path_follow
		print("New target: "+ str(body.target))
		print("New path follow: "+str(body.path_follow))
