extends Button

@onready var Menu = get_parent().get_parent().get_parent().get_parent()

func _on_pressed():
	Menu._ChapterChange(int(String(name)))
