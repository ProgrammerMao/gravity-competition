extends Control

var data = {
	"window_mode" : 0,
	"shadow" : true, 
	"msaa" : 0,
	"vsync" : false,
	"main_audio" : 1,
	"scene_audio" : 1,
	"music_audio" : 1,
	"dialogue_audio" : 1,
	"scene" : 0,
	"chapter" : 0
}
#DisplayServer.window_set_vsync_mode()

@onready var Adjust = $Adjust
@onready var Chapter = $Chapter

@onready var Scene = get_parent().get_parent().get_parent()

func _ready():
	Adjust.visible = false
	Chapter.visible = false
	_load()
	if get_parent().axis_lock_linear_x:
		$Background.visible = false
		$Button/Into.visible = true
		$Button/GoBack.visible = false
		$Button/Restart.visible = false
		$Button/Gravity.position = Vector2(55, -382)
	else:
		$Button/Into.visible = false
		$Button/GoBack.visible = true
		$Button/Restart.visible = true
		$Button/Gravity.position = Vector2(55, -427)
		_Menu()

func _Save():
	data.window_mode = $Adjust/Image/Resolution.selected
	data.shadow = $Adjust/Image/Shadow.selected
	data.msaa = $Adjust/Image/Antialias.selected
	data.main_audio = $Adjust/Audio/Main/Main.value
	data.scene_audio = $Adjust/Audio/Scene/Scene.value
	data.music_audio = $Adjust/Audio/Music/Music.value
	data.dialogue_audio = $Adjust/Audio/Dialogue/Dialogue.value
	
	
	var file = FileAccess.open("data.json",FileAccess.WRITE)
	file.store_line(JSON.stringify(data))
	file.close()

func _load():
	var file = FileAccess.open("data.json",FileAccess.READ)
	if FileAccess.get_open_error():
		_Save()
	else:
		var json_object = JSON.new()
		var result = json_object.parse(file.get_as_text())
		data = json_object.data
		file.close()
	
	$Adjust/Image/Resolution.selected = data.window_mode
	$Adjust/Image/Shadow.selected = data.shadow
	$Adjust/Image/Antialias.selected = data.msaa
	$Adjust/Audio/Main/Main.value = data.main_audio
	$Adjust/Audio/Scene/Scene.value = data.scene_audio
	$Adjust/Audio/Music/Music.value = data.music_audio
	$Adjust/Audio/Dialogue/Dialogue.value = data.dialogue_audio
	
	_on_resolution_item_selected(data.window_mode)
	_on_shadow_item_selected(data.shadow)
	_on_antialias_item_selected(data.msaa)
	
	_on_main_value_changed(data.main_audio)
	_on_scene_value_changed(data.scene_audio)
	_on_music_value_changed(data.music_audio)
	_on_dialogue_value_changed(data.dialogue_audio)
	
	if data.chapter < data.scene:
		data.chapter = data.scene
	
	if data.chapter > 0: #重力
		Chapter.get_node("List/List/1").disabled = false
	if data.chapter > 5: #跟随
		Chapter.get_node("List/List/2").disabled = false
	if data.chapter > 10: #弹射
		Chapter.get_node("List/List/3").disabled = false
	if data.chapter > 15: #反转
		Chapter.get_node("List/List/4").disabled = false
#	if data.chapter > 20: #进阶
#		Chapter.get_node("List/List/5").disabled = false

func _process(delta):
	if Input.is_action_just_pressed("Esc") and not get_parent().axis_lock_linear_x:
		_Menu()
	if Adjust.get_node("HeadLine").button_pressed:
		Adjust.top_level = true
		Chapter.top_level = false
	if Chapter.get_node("HeadLine").button_pressed:
		Adjust.top_level = false
		Chapter.top_level = true

func _Menu():
	if visible: #关闭
		visible = false
		Input.mouse_mode = 2
		get_tree().paused = false
	else: #开启
		visible = true
		Input.mouse_mode = 0
		get_tree().paused = true

func _input(event):
	if event is InputEventMouseMotion: #拖拽
		if Adjust.get_node("HeadLine").button_pressed:
			Adjust.position += event.relative
		if Chapter.get_node("HeadLine").button_pressed:
			Chapter.position += event.relative

func _on_chapter_pressed():
	if Chapter.visible:
		Chapter.visible = false
		Chapter.top_level = false
	else:
		Chapter.visible = true
		Chapter.top_level = true
		Adjust.top_level = false

func _on_adjust_pressed():
	if Adjust.visible:
		Adjust.visible = false
		Adjust.top_level = false
	else:
		Adjust.visible = true
		Adjust.top_level = true
		Chapter.top_level = false

func _on_go_back_pressed():
	_Menu()

func _on_restart_pressed():
	get_parent().get_parent().get_parent()._LoadNextScene(false)

func _on_bow_out_pressed():
	_Save()
	get_tree().quit()

func _on_shadow_item_selected(index):
	if index == 0:
		Scene.Shadow = true
	else:
		Scene.Shadow = false

func _on_resolution_item_selected(index):
	if index == 0:
		DisplayServer.window_set_mode(3)
	else:
#		Window.size
		DisplayServer.window_set_mode(0)

func _on_main_value_changed(value):
	AudioServer.set_bus_volume_db(0, linear_to_db(value))

func _on_scene_value_changed(value):
	AudioServer.set_bus_volume_db(1, linear_to_db(value))

func _on_music_value_changed(value):
	AudioServer.set_bus_volume_db(2, linear_to_db(value))

func _on_dialogue_value_changed(value):
	AudioServer.set_bus_volume_db(3, linear_to_db(value))

func _on_antialias_item_selected(index):
	if index == 0:
		get_viewport().msaa_3d = 0
	elif index == 1:
		get_viewport().msaa_3d = 1
	elif index == 2:
		get_viewport().msaa_3d = 2
	elif index == 3:
		get_viewport().msaa_3d = 3

func _ChapterChange(button_name):
	if button_name == 1:
		button_name = 0
	elif button_name <= 5:
		button_name = (button_name - 1) * 5 + 1
	Scene._LoadNextScene(false, button_name)


func _on_into_pressed():
	Scene._LoadNextScene(false, data.scene)
	
