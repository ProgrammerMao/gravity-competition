extends CharacterBody3D

var attribute = "Glass"

@onready var Frame = $Frame
@onready var RayCast = $RayCast

func _process(delta):
	if RayCast.get_node("1").is_colliding() and RayCast.get_node("1").get_collider().get_parent().name != "Prohibit" and RayCast.get_node("1").get_collider().attribute == "Glass":
		Frame.get_node("1").visible = false
	else:
		Frame.get_node("1").visible = true
	
	if RayCast.get_node("2").is_colliding() and RayCast.get_node("2").get_collider().get_parent().name != "Prohibit" and RayCast.get_node("2").get_collider().attribute == "Glass":
		Frame.get_node("2").visible = false
	else:
		Frame.get_node("2").visible = true
	
	if RayCast.get_node("3").is_colliding() and RayCast.get_node("3").get_collider().get_parent().name != "Prohibit" and RayCast.get_node("3").get_collider().attribute == "Glass":
		Frame.get_node("3").visible = false
	else:
		Frame.get_node("3").visible = true
	
	if RayCast.get_node("4").is_colliding() and RayCast.get_node("4").get_collider().get_parent().name != "Prohibit" and RayCast.get_node("4").get_collider().attribute == "Glass":
		Frame.get_node("4").visible = false
	else:
		Frame.get_node("4").visible = true
