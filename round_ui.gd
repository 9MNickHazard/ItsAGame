extends CanvasLayer


@onready var difficulty_label: Label = $DifficultyLabel
@onready var mobs_left_label: Label = $MobsLeftLabel
@onready var difficulty_manager: Node2D = get_node("/root/world/DifficultyManager")

func _ready() -> void:
	difficulty_label.text = "Difficulty: 1.0"
	#mobs_left_label.text = "Active Mobs: 0"

	difficulty_manager.difficulty_increased.connect(_on_difficulty_increased)
	#difficulty_manager.mobs_remaining_changed.connect(_on_mobs_remaining_changed)

func _on_difficulty_increased(new_difficulty: float) -> void:
	difficulty_label.text = "Difficulty: " + str(snappedf(new_difficulty, 0.1))
	
#func _on_mobs_remaining_changed(remaining_count: int) -> void:
	#mobs_left_label.text = "Active Mobs: " + str(remaining_count)
	
