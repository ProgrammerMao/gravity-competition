@tool
extends StaticBody3D

var attribute = "trigger"

var state = false

@export var Reversal = false
@export var Speed = 1.0

@onready var Up = $Up
@onready var Down = $Down
@onready var Collision = $Collision

func _process(delta):
	if get_parent().name == "Wall":
		state = true
	
	Up.state = state
	Down.state = state
	

func _trigger(value):
	if Reversal:
		if value:
			state = false
		else:
			state = true
	else:
		state = value
	
