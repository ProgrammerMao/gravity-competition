#@tool
extends CharacterBody3D

var attribute = "trigger"

var state = true

var play_delta = 3.0

var pitch_scale = 0.0
const STOP_NOBODY = 0.0
const STOP_RIGIDBODY = 0.9
const STOP_ANYTHING = 1.0

@export var Reversal = false
@export var Switch = false
@export var StopCharacter = false

@onready var Acoustics = $Acoustics

@onready var Model = $Model
@onready var Allow = $Model/Allow
@onready var Prohibit = $Model/Prohibit
@onready var CollisionShape = $Collision

@onready var AllowAnimation = $Model/AllowAnimation
@onready var ProhibitAnimation = $Model/ProhibitAnimation

@onready var Frame_1 = $Frame/Frame_1
@onready var Frame_2 = $Frame/Frame_2

@onready var Ray_1 = $Frame/Ray_1
@onready var Ray_2 = $Frame/Ray_2

#func _ready(): #!
#	$Model/Prohibit.visible = false

func _trigger(value):
	if Reversal:
		if value:
			state = false
		else:
			state = true
	else:
		state = value
	
func _process(delta):
	if play_delta > 2.9:
		Acoustics.playing = true
		play_delta = 0.0
	play_delta += delta
	
	Acoustics.pitch_scale = lerp(Acoustics.pitch_scale, pitch_scale, delta)
	
	if Ray_1.is_colliding() and Ray_1.get_collider().attribute == "Wall":
		Frame_1.visible = true
	else:
		Frame_1.visible = false

	if Ray_2.is_colliding() and Ray_2.get_collider().attribute == "Wall":
		Frame_2.visible = true
	else:
		Frame_2.visible = false
	
	if state:
		if Switch:
			if StopCharacter:
				_Allow()
			else:
				_Prohibit()
		else:
			if StopCharacter:
				_Prohibit()
			else:
				_Allow()
	else:
		if Switch:
			if StopCharacter:
				_Prohibit()
			else:
				_Allow()
				
		else:
			_Close()
	
func _Allow():
	pitch_scale = STOP_RIGIDBODY
	
	if Allow.light_energy != 1:
		AllowAnimation.play("Allow")
		
	if Prohibit.light_energy != 0:
		ProhibitAnimation.play_backwards("Prohibit")
	
	CollisionShape.disabled = false
	
	set_collision_layer_value(6, false)
	set_collision_layer_value(7, true)

func _Prohibit():
	pitch_scale = STOP_ANYTHING
	
	if Allow.light_energy != 0:
		AllowAnimation.play_backwards("Allow")
		
	if Prohibit.light_energy != 1:
		ProhibitAnimation.play("Prohibit")
		
	
	CollisionShape.disabled = false
	
	set_collision_layer_value(6, true)
	set_collision_layer_value(7, true)

func _Close():
	pitch_scale = STOP_NOBODY
	if Allow.light_energy != 0:
		AllowAnimation.play_backwards("Allow")
	if Prohibit.light_energy != 0:
		ProhibitAnimation.play_backwards("Prohibit")
	
	CollisionShape.disabled = true

