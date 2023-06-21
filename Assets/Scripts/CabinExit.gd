extends Area3D

@onready var deadbody = $DeadBody
@onready var anim_player = $DeadBody/AnimationPlayer
@onready var collision = $CollisionShape3D
@onready var scream = $AudioStreamPlayer3D


func _on_body_entered(body):
	pass
	if body is Player:
		deadbody.visible = true
		anim_player.play("mixamocom")
		scream.play()
		await get_tree().create_timer(0.2).timeout
		collision.disabled = true
