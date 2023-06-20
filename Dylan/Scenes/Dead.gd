extends Area3D

@onready var deadbody = $DeadBody
@onready var anim_player = $DeadBody/AnimationPlayer
@onready var collision = $CollisionShape3D
@onready var scream = $AudioStreamPlayer3D


func _on_body_entered(body):
	if body is Player:
		deadbody.visible = true
		scream.play()
		await get_tree().create_timer(0.1).timeout
		anim_player.play("mixamocom")
		await get_tree().create_timer(0.4).timeout
		collision.disabled = true

