extends CharacterBody3D
## Speed Variables
@export_range(1, 35, 1) var speed : float = 4 # m/s
@export_range(1, 5, 1) var walkingspeed : float = 4 # m/s
@export_range(0.1, 3.5, 0.1) var crouchingspeed : float = 2 # m/s
@export_range(0.1, 2.5, 0.1) var crawlingspeed : float = 1 # m/s
@export_range(0.1, 10,  0.1) var sprintspeed : float = 6 # m/s
@onready var sprint_timer = $SprintTimer

# Flashlight Variables
@onready var flashlight = $FlashlightPivot
@onready var flashlight_light = $FlashlightPivot/MeshModel/LightBeam
@export_range(1,30,1) var flashlightfollowspeed : float = 15

# General Variables

@export_range(10, 400, 1) var acceleration : float = 100 # m/s^2
@export_range(10, 400, 1) var deceleration : float = 100 # m/s^2
@export_range(1,10,1)  var knockback : float = 8.0

@export_range(0.1, 3.0, 0.1) var jump_height : float = 1 # m
@export_range(0.1, 3.0, 0.1) var mouse_sens : float = 1.5

# FOV Variables

@export_range(1,170,1) var base_fov = 80.0
@export_range(0.5,20,0.5)  var fov_change = 1.0

# Headbob Variables

@export_range (1,10,1) var bob_freq = 2.5
@export_range (0.01,1,0.01) var bob_amp = 0.08
@onready var t_bob = 0.0


var isCrouching = false
var isCrawling = false
var trueSpeed = walkingspeed

var jumping : bool

# Player hit signal
signal player_hit

var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")

var input_dir : Vector2 # Player input

var walk_vel : Vector3 # Walking velocity 
var grav_vel : Vector3 # Gravity velocity 
var jump_vel : Vector3 # Jumping velocity

@onready var head : Node3D = $Head
@onready var camera : Camera3D = $Head/Camera

func _ready() -> void:
	capture_mouse(true)

func _input(event : InputEvent) -> void:
	input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	if event is InputEventMouseMotion: _aim(event)
	if Input.is_action_just_pressed("jump"): jumping = true
	if Input.is_action_just_pressed("exit"): get_tree().quit()
	
	

func _physics_process(delta : float) -> void:
	velocity = _walk(delta) + _gravity(delta) + _jump(delta)
	
	#Headbob
	
	if (!isCrouching && !isCrawling):
		t_bob += delta * velocity.length() * float(is_on_floor())
		camera.transform.origin = _headbob(t_bob)
	
	#FOV 

	var velocity_clamped = clamp(velocity.length(), 0.5, sprintspeed * 2)
	var target_fov = base_fov + fov_change * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	
	
	# Lag flashlight movement with camera
	flashlight.rotation = lerp(flashlight.rotation, head.rotation, delta * flashlightfollowspeed)
	
	if Input.is_action_just_pressed("flashlight"):
		flashlight_light.visible = !flashlight_light.visible
	
	if Input.is_action_just_pressed("crouch"):
		if isCrouching == false:
			movementStateChange("crouch")
			trueSpeed = crouchingspeed
			
		elif isCrouching == true:
			movementStateChange("uncrouch")
			trueSpeed = walkingspeed
			
	elif Input.is_action_just_pressed("crawl"):
		if isCrawling == false:
			movementStateChange("crawl")
			trueSpeed = crawlingspeed
		elif isCrawling == true:
			movementStateChange("uncrawl")
			trueSpeed = walkingspeed
			
	if Input.is_action_pressed("sprint") and trueSpeed == walkingspeed:
		trueSpeed = sprintspeed
		print(trueSpeed)
	elif Input.is_action_just_released("sprint") and trueSpeed == sprintspeed:
		trueSpeed = walkingspeed
		print(trueSpeed)
		

	move_and_slide()

func capture_mouse(capture : bool) -> void:
	if capture:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) 
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _aim(event : InputEvent) -> void:
	var mouse_axis : Vector2 = event.relative if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED else Vector2.ZERO
	head.rotation.y -= mouse_axis.x * mouse_sens * .001
	head.rotation.x = clamp(head.rotation.x - mouse_axis.y * mouse_sens * .001, -1.5, 1.5)

func _walk(delta : float) -> Vector3:
	if input_dir:
		var camera_dir : Vector3 = head.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)
		walk_vel = walk_vel.move_toward(Vector3(camera_dir.x, 0, camera_dir.z).normalized() * trueSpeed, acceleration * delta)
	else:
		walk_vel = walk_vel.move_toward(Vector3.ZERO, deceleration * delta)
	return walk_vel

func _gravity(delta : float) -> Vector3:
	grav_vel = Vector3.ZERO if is_on_floor() else grav_vel.move_toward(Vector3(0, velocity.y - gravity, 0), gravity * delta)
	return grav_vel

func _jump(delta : float) -> Vector3:
	if jumping:
		jumping = false; if is_on_floor(): jump_vel = Vector3(0, sqrt(4 * jump_height * gravity), 0)
	else:
		jump_vel = Vector3.ZERO if is_on_floor() else jump_vel.move_toward(Vector3.ZERO, gravity * delta)
	return jump_vel

# State Machine To Determine if the player is standing, crouching,or crawling 
func movementStateChange(changeType):
	match changeType:
		"crouch":
			if isCrawling:
				$AnimationPlayer.play_backwards("CrouchToCrawl")
			else:
				$AnimationPlayer.play("StandingToCrouch")
			isCrouching = true
			changeCollisionShapeTo("crouching")
			isCrawling  = false
			print(trueSpeed)
			
		"uncrouch":
			$AnimationPlayer.play_backwards("StandingToCrouch")
			isCrouching = false
			isCrawling = false
			changeCollisionShapeTo("standing")
			print(trueSpeed)
		"crawl":
			if isCrouching:
					$AnimationPlayer.play("CrouchToCrawl")
			else:
					$AnimationPlayer.play("StandingToCrawl")
			isCrouching = false
			isCrawling  = true
			changeCollisionShapeTo("crawling")
			print(trueSpeed)
		"uncrawl":
			$AnimationPlayer.play_backwards("StandingToCrawl")
			isCrawling = false
			isCrouching = false
			changeCollisionShapeTo("standing")
			print(trueSpeed)
			
#Change collision shapes for standing, crouch, crawl
func changeCollisionShapeTo(shape):
	match shape:
		"crouching":
			#Disabled == false is enabled!
			$CrouchShape.disabled = false
			$CrawlShape.disabled = true
			$StShape.disabled = true
		"standing":
			#Disabled == false is enabled!
			$StShape.disabled = false
			$CrawlShape.disabled = true
			$CrouchShape.disabled = true
		"crawling":
			#Disabled == false is enabled!
			$CrawlShape.disabled = false
			$StShape.disabled = true
			$CrouchShape.disabled = true

# Emits the player hit signal causing the screen to flash red, further implentation for actual damage needed, health system?
func hit(dir):
	emit_signal("player_hit")
	velocity += dir * knockback


func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * bob_freq) * bob_amp
	pos.x = cos(time * bob_freq / 2) * bob_amp
	return pos
