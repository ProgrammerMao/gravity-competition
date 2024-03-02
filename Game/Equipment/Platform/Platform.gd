@tool
extends Node3D

var attribute = "trigger"

var state = false

@export var Place = true
@export var Move = false
@export var Chassis = true
@export var ChassisPosition = false
var Speed = 2.0
@export var Reversal = false
@export var Continued = false

@onready var TruePoint = $True
@onready var FalsePoint = $False

@onready var Wall_Up = $Wall_Up
@onready var Wall_Down = $Wall_Down
@onready var ToCore_UP = $ToCore_UP
@onready var ToCore_Down = $ToCore_Down

@onready var PlaceTrue = $Mesh/True
@onready var PlaceFalse = $Mesh/False

@onready var ChassisNode = $Chassis
@onready var ChassisWall = $Chassis/Wall_Chassis

@onready var Correct = $PlatformCorrect

func _trigger(value):
	if Reversal:
		if value:
			state = false
		else:
			state = true
	else:
		state = value

func _process(delta):
	_on_timer_timeout()
	Wall_Up.Place = Place
	Wall_Down.Place = Place
	
	Wall_Up.Lattice = true
	Wall_Down.Lattice = true
	
	ToCore_UP.monitoring = Place
	ToCore_Down.monitoring = Place
	
	if Chassis and Move:
		ChassisNode.visible = true
		ChassisWall.get_node("Collision").disabled = false
	else:
		ChassisNode.visible = false
		ChassisWall.get_node("Collision").disabled = true
	
	if Place:
		PlaceTrue.visible = true
		PlaceFalse.visible = false
	else:
		PlaceTrue.visible = false
		PlaceFalse.visible = true
	
	if Move:
		if ChassisPosition:
			ChassisNode.global_position = TruePoint.global_position
			ChassisNode.global_rotation = TruePoint.global_rotation
		else:
			ChassisNode.global_position = FalsePoint.global_position
			ChassisNode.global_rotation = FalsePoint.global_rotation
		
		if Continued:
			pass
		else:
			var location = Vector3()
			var angle = Vector3()
			if state:
				location = TruePoint.global_position
				angle = TruePoint.global_rotation
			else:
				location = FalsePoint.global_position
				angle = FalsePoint.global_rotation
				
			if state:
				global_position = global_position.move_toward(location, delta * Speed)
				if (global_position-location).length() < 0.001:
					
					global_rotation = global_rotation.move_toward(angle, delta * Speed)
			else:
				global_rotation = global_rotation.move_toward(angle, delta * Speed)
				if global_rotation == angle:
					global_position = global_position.move_toward(location, delta * Speed)
	
	for i in Wall_Up.Correct.get_children():
		i.disabled = true
		i.get_node("RayCast3D").enabled = false

	for i in Wall_Down.Correct.get_children():
		i.disabled = true
		i.get_node("RayCast3D").enabled = false

	for i in ChassisWall.Correct.get_children():
		i.disabled = true
		i.get_node("RayCast3D").enabled = false

func _on_timer_timeout():
	
	for i in Correct.get_children():
		var RayCast = i.get_node("RayCast3D")
		if Place:
			RayCast.enabled = true
			var body = RayCast.get_collider()
			if body:
				if body.name == "Wall_Up" or body.name == "Wall_Down":
					i.disabled = true
				else:
					i.disabled = false
