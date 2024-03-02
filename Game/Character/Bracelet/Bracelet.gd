extends Node3D

var mouse_occupy = false
var object = null #拾取物体
var delta_time = 0.0 #时间
var follow = false
var catapult = false

var pick_time = 0.0

var lift = true
var unfold = false

var lift_time = 0.0

var rotation_velocity = 0.0

var WORLD_GRAVITY = ProjectSettings.get_setting("physics/3d/default_gravity_vector")
const PRESS_TIME = 0.25 #按下时间
const PULL_PRESS = 10.0 #拾取速度
const GRAVITY_RADIUS = 1.5 #半径
const HAND_SPEED = 15.0 #抬手速度
const ROTATION_SPEED = 360.0 #旋转速度
const LIFT_DELTA = 0.3
const PICK_DELTA = 0.2

@onready var RayCast = $RayCast
@onready var Animated = $Animation
@onready var HandAnimated = $Mesh/Hand/Hand/AnimationPlayer

@onready var MainCast = $MainCast #设备

@onready var MarkerPoint = $MainCast/Marker

@onready var Gravity = $Mesh/Equipment/Gravity #重力
@onready var Wormhole = $Mesh/Equipment/Wormhole #虫洞

@onready var MeshNode = $Mesh/Bracelet
@onready var Equipment = $Mesh/Equipment

@onready var Character = get_parent().get_parent()

func _ready():
	

	Gravity._Close()
	Gravity._Guide(false, false)

func _process(delta):
	if lift:
		if not unfold:
			if LIFT_DELTA < lift_time:
				Animated.current_animation = "Up"
				HandAnimated.current_animation = "Lift"
				unfold = true
		lift_time = 0.0
		rotation_velocity = lerp(rotation_velocity, ROTATION_SPEED, delta)
		
	else:
		if unfold:
			if LIFT_DELTA < lift_time:
				Animated.current_animation = "Down"
				HandAnimated.current_animation = "Put"
				unfold = false
		lift_time += delta
		rotation_velocity = lerp(rotation_velocity, 0.0, delta)
	
	MeshNode.rotation.x += deg_to_rad(rotation_velocity * delta)
	Equipment.rotation.x += deg_to_rad(rotation_velocity * delta)
	
	Gravity.Follow = Character.Follow
	Gravity.Catapult = Character.Catapult

func _physics_process(delta):
	_Pick(delta)
	if Character.Gravity:
		Gravity.visible = true
		_Gravity(delta)
	else:
		Gravity.visible = false

#功能
func _Pick(delta): #拾取
	if Input.is_action_just_pressed("E"):
		pick_time = 0.0
		lift = true
		var body = RayCast.get_collider()
		if body and not object:
			if body.attribute == "button":
				body._trigger()
			
			if not object and body and body.attribute == "RigidBody":
				object = body
				mouse_occupy = true
		else:
			object = null
			mouse_occupy = false
	
	if object is RigidBody3D:
		
		var Point = MarkerPoint.global_position
		var Origin = object.global_position
		var amount = (Point - Origin) * delta * 100
		
		object.linear_velocity = amount * PULL_PRESS
		
		
		lift = true
		
		var object_rotation = object.global_rotation_degrees
		var marker_rotation = get_parent().get_parent().global_rotation_degrees
		
#		var rotation_amount = (marker_rotation - object_rotation)
		
		object.get_node("Collision").global_rotation_degrees = marker_rotation
		object.get_node("Model").global_rotation_degrees = marker_rotation
		object.get_node("Reversal").global_rotation_degrees = marker_rotation
			
		#放下
		if (Point - Origin).length() < 0.3:
			pick_time = 0.0
		else:
			pick_time += delta

		if pick_time > PICK_DELTA:
			object = null
		
	else:
		object = null
		if lift:
			lift = false

func _Gravity(delta): #重力
	#左键
	if Input.is_action_pressed("LeftButton") and not mouse_occupy:
		lift = true
		if (MainCast.get_collision_point() - Gravity.global_position).length() < GRAVITY_RADIUS and get_parent().get_parent().Follow:
			if Gravity.Area.monitoring and MainCast.get_collision_normal().dot(Gravity.global_transform.basis.y) > 0.5:
				follow = true
				Gravity._Follow(MainCast.get_collision_point(), delta)
		delta_time += delta
	elif Input.is_action_just_released("LeftButton"):
		if not lift and not mouse_occupy and not follow:
			if MainCast.get_collider() is StaticBody3D and MainCast.get_collider().Place:
				Gravity.up_direction = MainCast.get_collision_normal() #法线
				Gravity._DirectionCorrect()
				Gravity.global_position = MainCast.get_collision_point() #位置
				Gravity.motion_plane = Plane(MainCast.get_collision_normal() ,MainCast.get_collision_point())
				Gravity._Start()
				Gravity._Guide(true, false)
				lift = false
		follow = false
		mouse_occupy = false
		Gravity.hijack_node = null
		delta_time = 0.0
	
	#右键
	if Input.is_action_pressed("RightButton") and Gravity.Area.monitoring:
		mouse_occupy = true
		delta_time += delta
		if delta_time > PRESS_TIME:
			lift = true
			Gravity._Guide(true, true)
			if Input.is_action_just_pressed("LeftButton") and get_parent().get_parent().Catapult:
				Gravity._Catapult()
				catapult = true
				lift = false
		
	elif Input.is_action_just_released("RightButton"):
		Gravity._Guide(true, false)
		if delta_time < PRESS_TIME and not catapult:
			Gravity._Guide(false, false)
			Gravity.hijack_node = null
		
		if Input.is_action_pressed("LeftButton"):
			mouse_occupy = true
		else:
			mouse_occupy = false
		delta_time = 0.0
		catapult = false

