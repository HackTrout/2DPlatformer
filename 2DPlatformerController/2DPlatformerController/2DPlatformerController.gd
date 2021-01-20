extends KinematicBody2D

#Motion Variables
export(float) var speed = 25.0
export(float) var max_speed = 250.0
export(float, 0.0, 1.0, 0.01) var damping = 0.88
export(float) var gravity = 18.0
export(float) var min_jump_speed = -10
export(float) var jump_speed = -500
var jumped : bool = false
var motion := Vector2.ZERO

#Scale Variables
var current_direction : int = 1


func _ready() -> void:
	position = Vector2.ZERO


func _physics_process(delta):
	#Shadow
	var ray = $ShadowCast
	var shadow = get_parent().get_node("Shadow")
	shadow.visible = false
	if ray.is_colliding():
		shadow.visible = true
		shadow.global_position = ray.get_collision_point()
		
		#Resize Shadow
		var factor = 1.0 - ((shadow.global_position - global_position).length() / ray.cast_to.length())
		shadow.scale = Vector2.ONE * clamp(factor, 0.25, 1.0) * 3.0
	
	#Input----------------------------------------------
	if Input.is_action_just_pressed("mo_jump"):
		$Timers/JumpPressTimer.start()
	
	#Motion-------------------------------------------
	
	#Horizontal
	var xaxis = int(Input.is_action_pressed("mo_right")) - int(Input.is_action_pressed("mo_left"))
	motion.x = clamp(motion.x + (xaxis * speed), -max_speed, max_speed)
	
	#Changing Body
	if xaxis != 0:
		#Changing Direction
		current_direction = xaxis
		$PlayerBody.scale.x = xaxis
		
		#Run Animation
		if $PlayerBody/Body/AnimationPlayer.current_animation != "Run":
			$PlayerBody/Body/AnimationPlayer.play("Run")
	else:
		#Idle Animation
		if $PlayerBody/Body/AnimationPlayer.current_animation != "Idle":
			$PlayerBody/Body/AnimationPlayer.play("Idle")
	
	#Vertical
	if is_on_floor():
		#Set Grounded Timer
		$Timers/GroundedTimer.start()
		
		#Reset Jumped
		jumped = false
	else:
		#Falling
		motion.y += gravity
	
	#Jumping
	if !$Timers/JumpPressTimer.is_stopped() && !$Timers/GroundedTimer.is_stopped():
		#Set Motion
		motion.y = jump_speed
		jumped = true
		
		#Stop Timers
		$Timers/JumpPressTimer.stop()
		$Timers/GroundedTimer.stop()
	
	#Min Jump Speed
	if Input.is_action_just_released("mo_jump") && jumped:
		motion.y = max(min_jump_speed, motion.y)
	
	#Move
	motion = move_and_slide(motion, Vector2.UP)
	
	#Damping
	if xaxis == 0: motion.x *= damping
