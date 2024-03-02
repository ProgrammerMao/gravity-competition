@tool
extends StaticBody3D

var attribute = "Wall"

@export var Place = true
@export var Lattice = true

@onready var Allow = $Wall/Allow
@onready var Prohibit = $Wall/Prohibit

@onready var Correct = $Correct

@onready var SingleTrue = $Wall/Allow/Single
@onready var SingleFalse = $Wall/Prohibit/Single

var already = false

func _ready():
	_on_timer_timeout()
	if global_transform.basis.z.y == 1 or global_transform.basis.z.y == -1:
		Lattice = false
	else:
		Lattice = true
	rotation_degrees.z = 0

func _process(delta):
	if Lattice:
		Allow.get_node("Lattice").visible = true
		Prohibit.get_node("Lattice").visible = true
		
		Allow.get_node("Allow").visible = false
		Prohibit.get_node("Prohibit").visible = false
	else:
		Allow.get_node("Lattice").visible = false
		Prohibit.get_node("Lattice").visible = false
		
		Allow.get_node("Allow").visible = true
		Prohibit.get_node("Prohibit").visible = true


func _on_timer_timeout():
	for i in Correct.get_children():
		var RayCast = i.get_node("RayCast3D")
		if Place:
			RayCast.enabled = true
			var body = RayCast.get_collider()
			if body:
				if body is StaticBody3D or body.attribute == "Character" or body.name == "Correct":
					i.disabled = true
				else:
					i.disabled = false
		else:
			RayCast.enabled = false
			
			Allow.visible = false
			Prohibit.visible = true
			
			i.disabled = false
