extends Area3D

@onready var audio = $CollisionShape3D/AudioStreamPlayer3D

	

func _on_body_entered(body):
	if body is Player:
		audio.play()
		
		
