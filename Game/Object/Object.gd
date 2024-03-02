#@tool
extends RigidBody3D

var attribute = "RigidBody"

@export var Reversal = false

@onready var Light = $Light
@onready var True = $Reversal/True
@onready var False = $Reversal/False

var collide_old = 0
@onready var Acoustics_Collide = $Collide

var gravity_direction = Vector3(0, 1, 0) #重力向量
var Gravity_Value = ProjectSettings.get_setting("physics/3d/default_gravity")

func _process(delta):
	if Reversal:
		Light.light_negative = true
		True.visible = true
		False.visible = false
	else:
		Light.light_negative = false
		True.visible = false
		False.visible = true


func _physics_process(delta):
	if Reversal:
		apply_central_force(gravity_direction * Gravity_Value * mass)
	else:
		apply_central_force(-gravity_direction * Gravity_Value * mass)
	
	var collide_new = get_contact_count()
	if collide_new > collide_old:
		if not Acoustics_Collide.playing:
#			Acoustics_Collide.volume_db = linear_velocity.length() * 10 - 60
			Acoustics_Collide.play(0.04)

	collide_old = collide_new

