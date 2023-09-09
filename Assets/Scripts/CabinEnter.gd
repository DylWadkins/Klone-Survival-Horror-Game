extends Area3D

@onready var help = $Help
@onready var collision = $CollisionShape3D
@onready var extcollision = $CabinExit/CollisionShape3D

func _on_body_entered(body):
	if body is Player:
		await get_tree().create_timer(0.5).timeout
		help.play()
		await get_tree().create_timer(0.1).timeout
		collision.disabled = true
		extcollision.disabled = false
		
		
