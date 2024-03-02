extends CharacterBody3D

var attribute = "gravity"

var body_list = []

var state = false

var hijack_node = null

var play_delta = 3.0

@export var Alone = true
@export var Reversal = false
@export var Follow = false
@export var Catapult = false

@onready var Area = $Area
@onready var Collision = $Collision
@onready var RayCast = $RayCast

@onready var Acoustics = $Acoustics

@onready var GuideNode = $Guide
@onready var GravityAnimation = $Guide/GravityAnimation
@onready var CatapultAnimation = $Guide/CatapultAnimation
@onready var GravityNode = $Guide/Gravity
@onready var CatapultNode = $Guide/Catapult

@onready var Actual = $Mesh/Actual
@onready var Pluggable = $Mesh/Pluggable

const CORRECT_SPEED = 0.3 #修正速度
const CATAPULT_SPEED = 15.0 #弹射速度
const FOLLOW_SPEED = 5.0 #跟随速度
const ROTATION_SPEED = 15.0 #旋转速度
var WORLD_GRAVITY = ProjectSettings.get_setting("physics/3d/default_gravity_vector")

var motion_plane = Plane()

func _ready():
	up_direction = global_transform.basis.y
	if Alone:
		_Start()

func _trigger(value):
	if Reversal:
		if value:
			state = false
		else:
			state = true
	else:
		state = value
	
	if state:
		if not Area.monitoring:
			if Catapult:
				_Guide(false, true)
				_Start(true)
			else:
				_Guide(true, false)
				_Start()
	else:
		if Area.monitoring:
			if Catapult:
				if $Animation.current_animation != "Close_Catapult":
					_Catapult()
			else:
				_Guide(false, false)

#控制
func _Start(catapult = false):#启动.
	Collision.disabled = false
	GuideNode.visible = true
	top_level = true
	Area.monitoring = true
	
	$Twist.visible = true
	
	if catapult:
		$Animation.current_animation = "Start_Catapult"
	else:
		$Animation.current_animation = "Start"
		GravityAnimation.current_animation = "Gravity_Start"
	
	if not  Alone:
		Actual.visible = true
		Pluggable.visible = false
		Collision.disabled = false
	
	

func _Close():#关闭
	Collision.disabled = true
	GuideNode.visible = false
	top_level = false
	Area.monitoring = false
	
	if Alone:
		Actual.visible = true
		Pluggable.visible = false
		Collision.disabled = false
	else:
		Actual.visible = false
		Pluggable.visible = true
		Collision.disabled = true
	
	for i in body_list:
		_body_exited(i)

func _DirectionCorrect():
	global_transform.basis.y = up_direction
	global_transform.basis.x = up_direction.cross(global_transform.basis.z)
	global_transform.basis = global_transform.basis.orthonormalized()

#功能
func _process(delta):
	if play_delta > 2.9:
		Acoustics.playing = true
		play_delta = 0.0
	play_delta += delta
	
	if Area.monitoring:
		$Guide.rotation.y -= deg_to_rad(ROTATION_SPEED * delta)
		$Mesh.rotation.y -= deg_to_rad(ROTATION_SPEED * delta)
	else:
		$Guide/Animation.current_animation = "Close"
	
	if Alone:
		Actual.visible = true
		Pluggable.visible = false
	else:
		if not Area.monitoring:
			global_transform = get_parent().global_transform

func _physics_process(delta):
	for i in body_list:
		var s1 = global_transform.origin #第一参照点
		var s2 = Area.get_node("Collision").global_transform.origin #第二参照点
		var body_point = i.get_node("Collision").global_position #目标物体位置
		var target_point = Geometry3D.get_closest_point_to_segment_uncapped(body_point, s1, s2) #最近位置
		var correct_amount = (target_point - body_point) * CORRECT_SPEED #修正距离
		
		#分别管理
		if i.attribute == "Character":
			if not i.correct_stand:
				i.velocity += correct_amount
			elif Follow:
				if i.gravity_direction != up_direction:
					i.correct_stand = false
					i.gravity_direction = up_direction
					i._DirectionCorrect(false)
				var point = Geometry3D.get_closest_point_to_segment_uncapped(s1, body_point, i.global_position)
				_Follow(point, delta)
			
		elif i.attribute == "RigidBody":
			i.apply_central_impulse(correct_amount)
	if top_level:
		move_and_slide()
		if hijack_node:
			up_direction = hijack_node.global_transform.basis.y
			_DirectionCorrect()
			motion_plane = Plane(hijack_node.global_transform.basis.y, hijack_node.global_position)
		global_position -= motion_plane.distance_to(global_position) * up_direction
		
	velocity = Vector3()

func _Catapult(): #弹射
	if Catapult:
		for i in body_list:
			#分别管理
			if i.attribute == "Character":
				i.can_move = false
				i.velocity += CATAPULT_SPEED * up_direction
			elif i.attribute == "RigidBody":
				if i.Reversal:
					i.linear_velocity -= CATAPULT_SPEED * up_direction
				else:
					i.linear_velocity += CATAPULT_SPEED * up_direction
	_Guide(false, false)

func _Follow(point, delta): #跟随
	var amount = (point - global_position) * FOLLOW_SPEED
	global_position += amount * delta

#检测
func _body_entered(body): #进入
	if body.attribute  == "Character" or body.attribute == "RigidBody":
		body.gravity_direction = up_direction
		if body.attribute == "Character":
			body.correct_stand = false
		body_list.append(body)

func _body_exited(body): #离开
	if body.attribute  == "Character" or body.attribute == "RigidBody":
		body.gravity_direction = WORLD_GRAVITY
		if body.attribute == "Character":
			body._DirectionCorrect(true)
		body_list.erase(body)

func _Guide(gravity, catapult):
	if catapult:
		if not CatapultNode.visible:
			$Guide/Animation.stop()
			CatapultAnimation.current_animation = "Catapult_Start"
			GravityAnimation.current_animation = "Gravity_Close"
		if GravityAnimation.current_animation != "Gravity_Close":
			$Guide/Animation.current_animation = "Catapult"
		GuideNode.visible = true
		
	elif gravity:
		if CatapultNode.visible and CatapultAnimation.current_animation != "Catapult_Gravity":
			CatapultAnimation.current_animation = "Catapult_Gravity"
			GravityAnimation.current_animation = "Gravity_Start"
		
		$Guide/Animation.current_animation = "Gravity"
		
		GuideNode.visible = true
		
	else:
		$Guide/Animation.current_animation = "Close"
		CatapultAnimation.current_animation = "Close"
		GravityAnimation.current_animation = "Close"
		if Area.monitoring:
			
			if CatapultNode.visible:
				$Animation.current_animation = "Close_Catapult"
			else:
				$Animation.current_animation = "Close"

func _on_animation_animation_finished(anim_name):
	if anim_name == "Close" or anim_name == "Close_Catapult":
		_Close()
