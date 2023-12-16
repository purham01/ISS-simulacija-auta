extends Camera3D

@onready var car = $"../.."
@onready var camera_pivot = $".."

func _process(delta):
	camera_pivot.global_position = camera_pivot.global_position.lerp(car.global_position,1)
