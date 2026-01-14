class_name Player extends CharacterBody2D

signal laser_shot(laser)
signal died


@export var acceleration := 10.0
@export var max_speed := 350.0
@export var rotation_speed := 150.0

@onready var muzzle = $Muzzle
@onready var sprite = $Sprite2D

var laser_scene = preload("res://scenes/laser.tscn")

var shoot_cd = false
var rate_of_fire = 0.02

var alive := true

func _process(delta):
	if Input.is_action_pressed("shoot"):
		if !shoot_cd:
			shoot_cd = true
			shoot_laser()
			await get_tree().create_timer(rate_of_fire).timeout
			shoot_cd = false

func _physics_process(delta):
	var input_vector := Vector2(0, Input.get_axis("move_forward", "move_backward"))
	#Input.get_axis returns 0,1,-1 which is used to make a vector that has only vertical magnitude
	velocity += input_vector.rotated(rotation) * acceleration
	velocity = velocity.limit_length(max_speed)
	#limits the max velocity using a constant
	
	
	if Input.is_action_pressed("rotate_right"):
		rotate(deg_to_rad(rotation_speed*delta))
	if Input.is_action_pressed("rotate_left"):
		rotate(deg_to_rad(-rotation_speed*delta))
	#rotates player both directions
		
	if input_vector.y == 0:
		velocity = velocity.move_toward(Vector2.ZERO, 3)
		#sets velocity to 0 in increments
	
	move_and_slide()
	
	var screen_size = get_viewport_rect().size
	if global_position.y < 0:
		global_position.y = screen_size.y
	elif global_position.y > screen_size.y:
		global_position.y = 0
	#teleports player to top/bottom when trying to go out of bounds
	
	if global_position.x < 0:
		global_position.x = screen_size.x
	elif global_position.x > screen_size.x:
		global_position.x = 0
	#	#teleports player to side when trying to go out of bounds



func shoot_laser():
	var l = laser_scene.instantiate()
	l.global_position = muzzle.global_position
	l.rotation = rotation
	emit_signal("laser_shot",l)
	
func die():
	if alive==true:
		alive = false
		emit_signal("died")
		sprite.visible = false
		process_mode = Node.PROCESS_MODE_DISABLED

func respawn(pos):
	if alive==false:
		alive = true
		global_position = pos
		velocity = Vector2.ZERO
		sprite.visible = true
		process_mode = Node.PROCESS_MODE_INHERIT
