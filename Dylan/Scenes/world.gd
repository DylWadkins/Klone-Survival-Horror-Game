extends Node3D

@onready var player = $Player
@onready var hit_rect = $UI/hit_rect

func _physics_process(delta):
		pass
		#get_tree().call_group("enemies", "update_target_location", player.global_transform.origin)


# Makes a damage screen visible for a short time indicating the player got hit. 
func _on_player_player_hit():
	hit_rect.visible = true
	await get_tree().create_timer(0.4).timeout
	hit_rect.visible = false
