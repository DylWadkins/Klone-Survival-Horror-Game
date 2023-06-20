extends Area3D

@onready var deadbody = $DeadBody
@onready var anim_play = $DeadBody/AnimationPlayer

func _on_body_entered(body):
	if body is Player:
		deadbody.visible = true
		anim_play.play("mixamocom")
		

