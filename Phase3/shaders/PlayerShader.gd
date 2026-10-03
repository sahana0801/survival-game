extends AnimatedSprite2D
@onready var shader_material : ShaderMaterial = self.material

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if PlayerStats.player_hit:
		self.material = shader_material
	else:
		self.material = null
	
