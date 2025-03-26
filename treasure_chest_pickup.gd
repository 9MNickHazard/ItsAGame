extends Area2D
@onready var TreasureChestScene = load("res://scenes/treasure_chest_scene.tscn")
@onready var stats_manager: Node2D = get_node("/root/world/StatsManager")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		get_tree().paused = true
		var treasure_chest_scene = TreasureChestScene.instantiate()
		get_node("/root/world").add_child(treasure_chest_scene)
		stats_manager.total_chests_collected += 1
		queue_free()
