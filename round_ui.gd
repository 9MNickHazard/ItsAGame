extends CanvasLayer


@onready var round_label: Label = $RoundLabel
@onready var round_manager = get_node("/root/world/RoundManager")
@onready var mobs_left_label: Label = $MobsLeftLabel

func _ready():
	round_label.text = "Round: 1"
	mobs_left_label.text = "Mobs Left: 0"

	round_manager.round_started.connect(_on_round_started)
	round_manager.mobs_remaining_changed.connect(_on_mobs_remaining_changed)

func _on_round_started(round_number):
	round_label.text = "Round: " + str(round_number)
	
func _on_mobs_remaining_changed(remaining_count):
	mobs_left_label.text = "Mobs Left: " + str(remaining_count)
	
