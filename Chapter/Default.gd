extends Node3D

var Level = 0

var Origin = false

var chapter_path = ["res://Chapter/1_Gravity/0_Initial.tscn", #0 初始
					#第一章 重力
					"res://Chapter/1_Gravity/1_Gravity.tscn", #1 重力
					"res://Chapter/1_Gravity/2_Attempt.tscn", #2 运用
					"res://Chapter/1_Gravity/3_Control.tscn", #3 控制
					"res://Chapter/1_Gravity/4_Sever.tscn", #4 分隔
					"res://Chapter/1_Gravity/5_Symmetric.tscn", #5 轴对称
					#第二章 跟随
					"res://Chapter/2_Follow/6_Follow.tscn", #6 跟随
					"res://Chapter/2_Follow/7_Attempt.tscn", #7 运用
					"res://Chapter/2_Follow/8_Control.tscn", #8 控制
					"res://Chapter/2_Follow/9_Gallery.tscn", #9 长廊
					"res://Chapter/2_Follow/10_Chinampa.tscn", #10 浮岛
					#第三章 弹射
					"res://Chapter/3_Catapult/11_Catapult.tscn", #11 弹射
					"res://Chapter/3_Catapult/12_Attempt.tscn", #12 运用
					"res://Chapter/3_Catapult/13_Control.tscn", #13 控制
					"res://Chapter/3_Catapult/14_Tilt.tscn", #14
					"res://Chapter/3_Catapult/15_Stripe.tscn", #15
					#第四章 反转
					"res://Chapter/4_Reversal/16_Gravity.tscn", #16 #重力
					"res://Chapter/4_Reversal/17_Follow.tscn", #17 跟随
					"res://Chapter/4_Reversal/18_Catapult.tscn", #18 弹射
					"res://Chapter/4_Reversal/19_Symmetry.tscn", #19 中心对称
					"res://Chapter/4_Reversal/20_Upstairs.tscn", #20 上层
					#第五章 挑战
					"", #临时
					"res://Chapter/5_Challenge/21_T_shaped.tscn", #21 T形
					"res://Chapter/5_Challenge/22_Precipice.tscn", #22 断崖
					"res://Chapter/5_Challenge/23_Bridge.tscn", #23 桥
					"res://Chapter/5_Challenge/24_Passage.tscn", #长廊
					"res://Chapter/5_Challenge/25_Block.tscn", #25 阻断
					]

@export var To_Load = true
@export var To_Stop = false
@export var LOAD_SPEED = 10
@export var Shadow = true

@onready var Wall = $Wall
@onready var Equipment = $Equipment
@onready var Lighting = $Lighting
@onready var Load = $Into/Load/CollisionShape3D
@onready var Detection = $Into/Equipment/Area

@onready var OriginCamera = $OriginCamera

func _ready():
	if name != "Origin" and To_Load:
		Load.shape.radius = 3.2
	if To_Load:
		var wall_child = Wall.get_children()
		for i in wall_child:
			i.visible = false
		
		var equipment_child = Equipment.get_children()
		for i in equipment_child:
			var child_child = i.get_children()
			for j in child_child:
				if not j is OmniLight3D or not j is Node3D:
					j.visible = false
		var light_child = Lighting.get_children()
		for i in light_child:
			i.visible = false
	

func _process(delta):
	get_parent().get_node("Music").can_play = true
	
	if To_Load and Detection.state:
		Load.shape.radius += LOAD_SPEED * delta
	var light_child = Lighting.get_children()
	
	for i in light_child:
		i.shadow_enabled = Shadow
		i.shadow_opacity = 0.5

#加载检测
func _on_load_body_entered(body):
	body.visible = true

func _on_load_area_entered(area):
	area.visible = true

#关卡切换
func _on_leave_body_entered(body):
	if body.attribute == "Character":
		_LoadNextScene(true)

func _LoadNextScene(next, indexes = int(String(name))):
	if next:
		indexes += 1
	
	var path = chapter_path[indexes]
	
	if path == "":
		path = "res://Chapter/Origin.tscn"
	
	$Into/Character/Menu.data.scene = indexes
	$Into/Character/Menu._Save()
	$Into/Character._ChangeScene(path)

func _physics_process(delta):
	pass
