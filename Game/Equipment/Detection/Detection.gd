#@tool
extends Area3D

var attribute = "detector"

var state = false
var BodyList = []

@export var Place = true
@export var CharacterBody = true
@export var RigidBody = true
@export var Overlap = false

@onready var Allow = $Boundary/Allow
@onready var Prohibit = $Boundary/Prohibit

@onready var TrueAnimation = $Trigger/TrueAnimation
@onready var FalseAnimation = $Trigger/FalseAnimation

@onready var True = $Trigger/True
@onready var False = $Trigger/False



#func _ready(): #!
#	$Trigger/False.visible = false

func _process(delta):
	
	if Overlap:
		visible = false
	
	
	if BodyList != []:
		state = true
		
		if True.get_node("1").light_energy != 0.5:
			TrueAnimation.play("True")
			
#			#!
#			$Trigger/True.visible = true
#			$Trigger/False.visible = false
			
		if False.get_node("1").light_energy != 0:
			FalseAnimation.play_backwards("False")
			
#			#!
#			$Trigger/False.visible = true
#			$Trigger/True.visible = true
			
		
	else:
		state = false
		
		if True.get_node("1").light_energy != 0:
			TrueAnimation.play_backwards("True")
			
			
		if False.get_node("1").light_energy != 0.5:
			FalseAnimation.play("False")
			
			
		
	$Wall.Place = Place
	$Wall.visible = false
	
	if Place:
		Allow.visible = true
		Prohibit.visible = false
	else:
		Allow.visible = false
		Prohibit.visible = true

func _on_body_entered(body):
	if body.name != "Correct" and body.attribute == "Character" and CharacterBody:
		BodyList.push_back(body)
	if body.name != "Correct" and body.attribute == "RigidBody" and RigidBody:
		BodyList.push_back(body)

func _on_body_exited(body):
	BodyList.erase(body)
	
