extends CharacterBody3D

var attribute = "Character"

var scene_path = ""

@export var Gravity = true
@export var Follow = true
@export var Catapult = true

#节点
@onready var Head = $Head
@onready var Tool = $Tool
@onready var ToolPoint = $Head/ToolPoint
@onready var Collision = $Collision

@onready var Menu = $Menu
@onready var Display = $Display

var wall_collide = false
var ceiling_collide = false
@onready var Acoustics_Collide = $Acoustics/Collide

var floor_collide = false
@onready var Acoustics_Jump = $Acoustics/Jump
@onready var Acoustics_Floor = $Acoustics/Contact_Floor

var walk_delta = 0.0
var walk_num = 0
@onready var Acoustics_Contact_1 = $Acoustics/Contact_Wall_1
@onready var Acoustics_Contact_2 = $Acoustics/Contact_Wall_2

#最终值
var move_vector = Vector3() #移动向量
var move_amount = Vector3() #移动偏移量
var gravity_amount = Vector3() #重力偏移量

var correct_stand = true #站立
var move_velocity = 0.0 #移动速度
@export var can_move = true

var gravity_direction = Vector3()

#常量
const WALK_SPEED = 2.5 #走路速度
const STOP_SPEED = 10.0 #停止速度
const JUMP_SPEED = 3.5 #跳跃速度

const TOOL_SPEED = 15.0 #工具速度

const HEAD_SPEED = 10.0 #头部速度
const HEAD_DIRECTION = 0.0 #头部角度

const STAND_SPEED = 5.0 #站起速度
const DEFAULT_HEIGHT = 1.2 #默认高度
const DEFAULT_POSITION = -0.5 #默认位置
const CORRECT_HEIGHT = 0.5 #修正高度
const CORRECT_POSITION = 0 #修正位置

const WALK_TIME = 0.5 #步间隔

var Gravity_Value = ProjectSettings.get_setting("physics/3d/default_gravity") #重力大小
var WORLD_GRAVITY = ProjectSettings.get_setting("physics/3d/default_gravity_vector") #重力方向

func _ready():
	if axis_lock_linear_x:
		$Tool.visible = false
	gravity_direction = WORLD_GRAVITY
	if not axis_lock_linear_x:
		Input.mouse_mode = 2
	else:
		Input.mouse_mode = 0


func _input(event):
	if not axis_lock_linear_x:
		if event is InputEventMouseMotion and Input.mouse_mode == 2:
			rotate_object_local(Vector3.UP, deg_to_rad(-event.relative.x * 0.075))
			Head.rotation.x -= deg_to_rad(event.relative.y * 0.075)
			Head.rotation.x = clamp(Head.rotation.x,deg_to_rad(-90),deg_to_rad(90))

func _physics_process(delta):
	_Move(delta)
	_PushRigidbody()
	#数值还原
	Head.rotation.z = lerp(Head.rotation.z, HEAD_DIRECTION, delta * HEAD_SPEED)
	Collision.shape.height = lerp(Collision.shape.height, DEFAULT_HEIGHT, delta * STAND_SPEED)
	Collision.position.y = lerp(Collision.position.y, DEFAULT_POSITION, delta * STAND_SPEED)
	
	#工具位置
	
	var tool_orientation = Tool.global_transform.basis
	
	var target_orientation = Head.global_transform.basis
	Tool.global_transform.origin = ToolPoint.global_transform.origin
	
	Tool.top_level = true
	
	Tool.global_transform.basis = lerp(tool_orientation, target_orientation, delta * TOOL_SPEED)
	
	if $Tool/Bracelet.object:
		Tool.top_level = false
#		Tool.global_transform.basis = lerp(tool_orientation, global_transform.basis, delta * TOOL_SPEED)
		Tool.rotation.x = clamp(Tool.rotation.x,deg_to_rad(-15),deg_to_rad(15))
#	else:
	
	Tool.top_level = true


#功能
func _Move(delta): #移动 
	move_vector = Vector3()
	var body_vector = global_transform.basis
	if Input.is_action_pressed("W"):
		move_vector -= body_vector.z
	elif Input.is_action_pressed("S"):
		move_vector += body_vector.z
	if Input.is_action_pressed("A"):
		move_vector -= body_vector.x
	elif Input.is_action_pressed("D"):
		move_vector += body_vector.x
	
	move_velocity = WALK_SPEED
	
	if is_on_floor() and can_move: #触地
		if not floor_collide:
			Acoustics_Floor.play(0.02)
			walk_delta = 0.0
			walk_num = 0
		
		if move_vector: #移动
			walk_delta += delta
			if walk_delta > WALK_TIME and not is_on_wall():
				walk_num += 1
				walk_delta = 0.0
				if walk_num % 2 != 0:
					Acoustics_Contact_1.play(0.01)
				else:
					Acoustics_Contact_2.play(0.02)
			
			velocity = move_velocity * move_vector
		else:
			walk_delta = 0.0
			walk_num = 0
			velocity = lerp(velocity, Vector3(), delta * STOP_SPEED)
			
		if Input.is_action_just_pressed("Space"): #跳跃
			if gravity_direction == up_direction:
				Acoustics_Jump.play(0.03)
				walk_delta = WALK_TIME + 1
				walk_num = 0
				velocity += gravity_direction * JUMP_SPEED
		
		floor_collide = true
	else:
		floor_collide = false
	
	if is_on_wall() or is_on_ceiling():
		if not is_on_floor(): #碰撞音效
			if is_on_wall() and not wall_collide:
				Acoustics_Collide.play(0.05)
				wall_collide = true
			if is_on_ceiling() and not ceiling_collide:
				Acoustics_Collide.play(0.05)
				ceiling_collide = true
			
		if gravity_direction != up_direction:
			if move_vector:
				velocity = move_velocity * move_vector
			velocity = lerp(velocity, Vector3(), delta * STOP_SPEED)
	else:
		wall_collide = false
		ceiling_collide = false
	
	if gravity_direction != up_direction:
		if is_on_wall() or is_on_ceiling() or is_on_floor():
			if Input.is_action_just_pressed("Space"):
				_DirectionCorrect(true)
	
	velocity = lerp(velocity, Vector3(), delta * 0.1)
	
	velocity -= gravity_direction * Gravity_Value * delta
	can_move = true
	move_and_slide()

func _PushRigidbody(): #推动刚体
	pass
	for i in get_slide_collision_count():
		var Collision = get_slide_collision(i)
		var object = Collision.get_collider(i)
		if object is RigidBody3D:
			object.apply_central_impulse(-Collision.get_normal(i) * 0.8)

func _DirectionCorrect(squat): #方向修正
	up_direction = gravity_direction
	
	correct_stand = true
	if squat:
		Collision.shape.height = CORRECT_HEIGHT
		Collision.position.y = CORRECT_POSITION
	
	Head.top_level = true
	global_transform.basis.y = up_direction
	global_transform.basis.x = up_direction.cross(global_transform.basis.z)
	global_transform.basis = global_transform.basis.orthonormalized()
	Head.top_level = false
	
	var towards = Head.rotation.z
	Head.rotation.z = HEAD_DIRECTION
		
	Head.top_level = true
	global_transform.basis.x = Head.global_transform.basis.x
	global_transform.basis.z = Head.global_transform.basis.x.cross(global_transform.basis.y)
	global_transform.basis = global_transform.basis.orthonormalized()
	Head.top_level = false
	
	Head.rotation.z = towards

func _ChangeScene(path):
	scene_path = path
	$Change/ChangeScene.play("Quit")

func _on_change_scene_animation_finished(anim_name):
	if anim_name == "Quit":
		$Change/ChangeScene.play("RESET")
		get_tree().change_scene_to_file(scene_path)
		
		
