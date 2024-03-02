extends CharacterBody3D

var attribute = "button"

var state = false
var trigger = false

var wait_delta = 0.0

@onready var Animatic = $Animation
@onready var True = $Button/True
@onready var False = $Button/False

@export var Switch = false
@export var WaitTime = 3.0

var acoustics_state = true
@onready var Acoustics_True = $Acoustics/True
@onready var Acoustics_False = $Acoustics/False

#func _ready(): #！
#	$Button/False.visible = false

func _trigger():
	if Switch:
		if state:
			state = false
		else:
			state = true
			
	else:
		state = true

func _process(delta):
	if state:
		if True.light_energy != 0.5:
			Animatic.play("Change")
			
#			#!
#			$Button/True.visible = true
#			$Button/False.visible = false
	else:
		if False.light_energy != 0.5:
			Animatic.play_backwards("Change")
			
#			#!
#			$Button/True.visible = false
#			$Button/False.visible = true
	
	if state and not Switch:
		if wait_delta < WaitTime:
			wait_delta += delta
		else:
			state = false
			wait_delta = 0.0
	
	if state:
		if not acoustics_state:
			Acoustics_False.play(0.22)
		acoustics_state = true
	else:
		if acoustics_state:
			Acoustics_False.play(0.22)
		acoustics_state = false
		
