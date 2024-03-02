extends Area3D

var attribute = "detector"

var state = false

@export var Reversal = false
@export var AnewLoad = false
@export var JustCharacter = false
@export var JustRigidBody = false

@onready var Collision = $CollisionShape3D

func _ready():
	if Reversal:
		state = true

func _on_body_entered(body):
	if JustCharacter:
		if body.name != "Correct" and body.attribute == "Character":
			if AnewLoad:
				get_parent().get_parent()._LoadNextScene(false)
			_trigger()
	if JustRigidBody:
		if body.attribute == "RigidBody":
			if AnewLoad:
				body.position = Vector3()
				body.rotation = Vector3()
				body.linear_velocity = Vector3()
				body.angular_velocity = Vector3()
				
			_trigger()
	else:
		if body.name != "Correct" and (body.attribute == "Character" or body.attribute == "RigidBody"):
			_trigger()

func _trigger():
	if Reversal:
		state = false
	else:
		state = true
	
	if not AnewLoad and name != "Load":
		if get_parent().attribute != "equipment":
			get_parent().Reversal = true

