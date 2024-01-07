extends Node3D

func set_dial(value):
	$SubViewport/DialFace.set_dial(value)

func _ready():
	var material : ShaderMaterial = $Face.material_override
	if material:
		material.set_shader_parameter("face", $SubViewport.get_texture())
