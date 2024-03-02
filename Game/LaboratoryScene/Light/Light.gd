extends OmniLight3D

@onready var Wall = $Wall

func _process(delta):
	if not visible and Wall.visible:
		visible = true
		Wall.visible = false
		
	if visible:
		Wall.set_collision_layer_value(1, false)
	
	
