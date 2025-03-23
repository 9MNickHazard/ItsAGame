extends Area2D
@onready var TreasureChestScene = load("res://scenes/treasure_chest_scene.tscn")


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		get_tree().paused = true
		var treasure_chest_scene = TreasureChestScene.instantiate()
		get_node("/root/world").add_child(treasure_chest_scene)
		
		queue_free()
