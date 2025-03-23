extends CanvasLayer

@onready var treasure_chest_animated_sprite: AnimatedSprite2D = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/CenterContainer4/AnimatedSprite2D
@onready var gem_count_label: Label = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/CenterContainer5/HBoxContainer/GemCountLabel
@onready var save_manager = get_node("/root/SaveManager")

var total_gems: int = 0

func _ready() -> void:
	gem_count_label.text = "0"
	
	await get_tree().create_timer(1.0).timeout
	
	treasure_chest_animated_sprite.play("ChestOpening")
	
	await treasure_chest_animated_sprite.animation_finished
	
	total_gems = randi_range(50, 300)
	
	var tween = create_tween()
	tween.tween_method(update_gem_count, 0, total_gems, 3.0)

func update_gem_count(value: int) -> void:
	gem_count_label.text = str(value)

func _on_continue_button_pressed() -> void:
	if save_manager:
		save_manager.add_gems(total_gems)
	
	get_tree().paused = false
	
	queue_free()
