extends Area3D

@onready var deadbody = $DeadBody
@onready var anim_player = $DeadBody/AnimationPlayer
@onready var collision = $CollisionShape3D
@onready var scream = $AudioStreamPlayer3D
@onready var plea = $AudioStreamPlayer3D2
@onready var cassette = $"Casette Trigger/CassetteS"


func _on_body_entered(body):
	pass
	if body is Player:
		deadbody.visible = true
		anim_player.play("mixamocom")
		scream.play()
		await get_tree().create_timer(1).timeout
		plea.play()
		await get_tree().create_timer(0.1).timeout
		cassette.disabled  = false
		collision.disabled = true
