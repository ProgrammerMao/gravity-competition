@tool
extends Area3D

var state = true

var attribute = "gravity"

@export var Mesh_1 = false
@export var Mesh_2 = false
@export var Mesh_3 = false
@export var Mesh_4 = false

@onready var True = $Mesh/True
@onready var False = $Mesh/False

@onready var True_1 = $Mesh/True/"1"
@onready var True_2 = $Mesh/True/"2"
@onready var True_3 = $Mesh/True/"3"
@onready var True_4 = $Mesh/True/"4"

@onready var False_1 = $Mesh/False/"1"
@onready var False_2 = $Mesh/False/"2"
@onready var False_3 = $Mesh/False/"3"
@onready var False_4 = $Mesh/False/"4"


func _trigger(value):
	if value:
		True.visible = true
		False.visible = false
	else:
		True.visible = false
		False.visible = true

func _process(delta):
	if Mesh_1:
		$Mesh/True/"1".visible = true
		$Mesh/False/"1".visible = true
	else:
		$Mesh/True/"1".visible = false
		$Mesh/False/"1".visible = false
	
	if Mesh_2:
		$Mesh/True/"2".visible = true
		$Mesh/False/"2".visible = true
	else:
		$Mesh/True/"2".visible = false
		$Mesh/False/"2".visible = false
	
	if Mesh_3:
		$Mesh/True/"3".visible = true
		$Mesh/False/"3".visible = true
	else:
		$Mesh/True/"3".visible = false
		$Mesh/False/"3".visible = false
	
	if Mesh_4:
		$Mesh/True/"4".visible = true
		$Mesh/False/"4".visible = true
	else:
		$Mesh/True/"4".visible = false
		$Mesh/False/"4".visible = false
