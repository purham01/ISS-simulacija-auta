extends ColorRect
@onready var dial = $Center/Dial

func set_dial(angle):
	dial.rotation_degrees = angle
