extends CanvasLayer


@onready var round_label: Label = $RoundLabel
@onready var wave_label: Label = $WaveLabel
@onready var round_manager = get_node("/root/world/RoundManager")

func _ready():
	round_label.text = "Round: 1"
	#wave_label.text = "Wave: 1"
	wave_label.visible = false
	
	# Connect signals from RoundManager
	round_manager.round_started.connect(_on_round_started)
	#round_manager.wave_started.connect(_on_wave_started)

func _on_round_started(round_number):
	round_label.text = "Round: " + str(round_number)
	
#func _on_wave_started(wave_number):
	#wave_label.text = "Wave: " + str(wave_number)
