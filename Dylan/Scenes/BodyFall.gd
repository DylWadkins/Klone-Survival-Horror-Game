extends Node3D

@onready var anim_player = $AnimationPlayer
@onready var body = $RootNode



func body_drop():
	anim_player.play("mixamocom")
	

