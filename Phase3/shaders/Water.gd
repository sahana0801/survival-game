extends Sprite2D

@onready var shader_material : ShaderMaterial = self.material

# Called when the node enters the scene tree for the first time.
func _ready():
	shader_material.set_shader_parameter("red", 1.0)
	shader_material.set_shader_parameter("green", 1.0)
	shader_material.set_shader_parameter("blue", 1.0)
	shader_material.set_shader_parameter("alpha", 1.0)
