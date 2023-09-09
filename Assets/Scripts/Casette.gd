extends Area3D

@onready var screech = $Creature
@onready var cassette = $Cassette
@onready var collision = $CassetteS
@onready var collect = $CanvasLayer/Label


func _on_body_entered(body):
	if body is Player:
		collect.visible = true
		cassette.visible = false
		await get_tree().create_timer(1.5).timeout
		collect.visible = false
		screech.play()
		await get_tree().create_timer(0.2).timeout
		collision.disabled = true
		
		
		
