extends Node3D

var attribute = "equipment"

var detector = [] #检测器
var trigger = [] #触发器

func _ready():
	var node = get_children()
	for i in node:
		if not i is OmniLight3D and i.name != "Stop":
			if i.attribute == "detector" or i.attribute == "button":
				detector.push_back(i)
			elif i.attribute == "trigger"  or i.attribute == "gravity":
				trigger.push_back(i)

func _process(delta):
	var state = true
	for i in detector:
		if not i.state:
			state = false
			
	for i in trigger:
		i._trigger(state)
