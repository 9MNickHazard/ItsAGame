extends Node

var sound_effects = {
	"goblin_death": []
}

func _ready():
	for i in range(1, 16):
		sound_effects["goblin_death"].append(load("res://assets/sounds/goblin-" + str(i) + ".wav"))
	

func play_sound(category: String, position: Vector2 = Vector2.ZERO, pitch_range: float = 0.1):
	if sound_effects.has(category) and sound_effects[category].size() > 0:
		var audioplayer = AudioStreamPlayer2D.new()
		add_child(audioplayer)
		
		var sound_index = randi() % sound_effects[category].size()
		audioplayer.stream = sound_effects[category][sound_index]
		audioplayer.pitch_scale = 1.0 + randf_range(-pitch_range, pitch_range)
		if category == "goblin_death":
			audioplayer.bus = "GoblinDeathSFX"
				
		audioplayer.global_position = position
		audioplayer.play()
		
		audioplayer.finished.connect(func(): audioplayer.queue_free())
