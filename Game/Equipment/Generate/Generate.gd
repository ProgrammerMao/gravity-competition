extends Area3D

var attribute = "trigger"

var state = false

@export var Reversal = false
@export var ObjectReversal = false
@export var CubeEnable = true

@onready var Cube = $Object/Cube

func _trigger(value):
	if Reversal:
		if value:
			state = false
		else:
			state = true
	else:
		state = value
	

func _process(delta):
	Cube.Reversal = ObjectReversal
