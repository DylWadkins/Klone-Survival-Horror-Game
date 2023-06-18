extends CharacterBody3D

var player = null
var state_machine

const SPEED = 5.0
const ATTACK_RANGE = 1.3

@export var player_path : NodePath

@onready var nav_agent = $NavigationAgent3D
@onready var anim_tree = $AnimationTree


func _ready():
	player = get_node(player_path)
	state_machine = anim_tree.get("parameters/playback")
	
	
func _process(delta):
	velocity = Vector3.ZERO
	
	# Switch statement based on the animationtree in enemy scene, can expand with unused animations like walk and idle
	match state_machine.get_current_node():
		"run":
			nav_agent.set_target_position(player.global_transform.origin)
			var next_nav_point = nav_agent.get_next_path_position()
			velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
			look_at(Vector3(global_position.x + velocity.x, global_position.y, global_position.z + velocity.z), 
			Vector3.UP)
		"attack":
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	
	
	## sets the animation of the enemy properly depending on the relation of the player to the enemy 
	anim_tree.set("parameters/conditions/attack", _target_in_range())
	anim_tree.set("parameters/conditions/run", !_target_in_range())
	
	
	anim_tree.get("parameters/playback")

	move_and_slide()
	
	
	
# Determines if the player is close enough for the enemy to atack using the ATTACK_RANGE var
func _target_in_range():
	return global_position.distance_to(player.global_position) < ATTACK_RANGE

# Function to determine if player is still in range when an attack occurs, if so calls the hit function in player.gd
func _hit_finished():
	if global_position.distance_to(player.global_position) < ATTACK_RANGE + 1.0:
		var dir = global_position.direction_to(player.global_position)
		player._hit(dir)

