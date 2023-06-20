extends Area3D

@onready var rustle = $Rustle

func _on_body_entered(body):
	if body is Player:
		rustle.play()
		
		
