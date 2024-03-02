extends Control

var delta_time = 48.0

var can_play = false

@onready var Bass1 = $Bass1
@onready var Bass2 = $Bass2
@onready var Drum = $Drum
@onready var Harmony = $Harmony
@onready var Melody = $Melody

func _physics_process(delta):
	if can_play:
		if not Harmony.playing:
			Harmony.play()
			Drum.play()
			Bass1.play()
			Bass2.play()
			Melody.play()
		
#		delta_time += delta
#		if delta_time >= 48.0:
#			Harmony.play()
#			Drum.play()
#			Bass1.play()
#			Bass2.play()
#			delta_time = 0.0
	
	play(delta)


func play(delta):
	var chapter = determine()
	
	Harmony.volume_db = lerp(Harmony.volume_db, 0.0, delta * 10)
	Drum.volume_db = lerp(Drum.volume_db, 0.0, delta * 10)
	
	if chapter >= 2:
		Bass1.volume_db = lerp(Bass1.volume_db, 0.0, delta * 10)
	else:
		Bass1.volume_db = lerp(Bass1.volume_db, -80.0, delta * 10)
	
	if chapter >= 3:
		Bass2.volume_db = lerp(Bass2.volume_db, 0.0, delta * 10)
	else:
		Bass2.volume_db = lerp(Bass2.volume_db, -80.0, delta * 10)
		
	if chapter >= 4:
		Melody.volume_db = lerp(Melody.volume_db, 0.0, delta * 10)
	else:
		Melody.volume_db = lerp(Melody.volume_db, -80.0, delta * 10)

func determine():
	var chapter = get_parent().get_child(1).get_node("Into/Character/Menu").data.scene
	if chapter > 20:
		return 5
	elif chapter > 15:
		return 4
	elif chapter > 10:
		return 3
	elif chapter > 5:
		return 2
	else:
		return 1
	
