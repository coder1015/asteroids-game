class_name Asteroid extends Area2D

signal exploded(pos, size, points)

var movement_vector := Vector2(0, -1)

enum AsteroidSize{LARGE, MEDIUM, SMALL}
@export var size := AsteroidSize.LARGE


var speed := 50

@onready var sprite = $Sprite2D
@onready var cshape = $CollisionShape2D

var points: int:
	get:
		match size:
			AsteroidSize.LARGE:
				return 100
			AsteroidSize.MEDIUM:
				return 50
			AsteroidSize.SMALL:
				return 25
			_:
				return 0

func _ready():
	rotation = randf_range(0, 2*PI)
	#randomly rotates asteroid
	match size:
			AsteroidSize.LARGE:
				speed = randf_range(5 ,200)
				sprite.texture = preload("res://asteroidassets/PNG/Meteors/meteorGrey_big1.png")
				#cshape.shape = preload("res://asteroidassets/resources/asteroid_cshape_large.tres")
				cshape.set_deferred("shape",preload("res://asteroidassets/resources/asteroid_cshape_large.tres"))
			AsteroidSize.MEDIUM:
				speed = randf_range(100,300)
				sprite.texture = preload("res://asteroidassets/PNG/Meteors/meteorGrey_med1.png")
				#cshape.shape = preload("res://asteroidassets/resources/asteroid_cshape_medium.tres")
				cshape.set_deferred("shape",preload("res://asteroidassets/resources/asteroid_cshape_medium.tres"))
			AsteroidSize.SMALL:
				speed = randf_range(200,500)
				sprite.texture = preload("res://asteroidassets/PNG/Meteors/meteorGrey_tiny1.png")
				#cshape.shape = preload("res://asteroidassets/resources/asteroid_cshape_small.tres")
				cshape.set_deferred("shape",preload("res://asteroidassets/resources/asteroid_cshape_small.tres"))

func _physics_process(delta):
	global_position += movement_vector.rotated(rotation) * speed * delta
	var radius = cshape.shape.radius
	var screen_size = get_viewport_rect().size
	if global_position.y+radius < 0:
		global_position.y = screen_size.y+radius
	elif global_position.y-radius > screen_size.y:
		global_position.y = -radius
	#teleports asteroids to top/bottom when trying to go out of bounds
	
	if global_position.x+radius < 0:
		global_position.x = screen_size.x
	elif global_position.x-radius > screen_size.x:
		global_position.x = -radius
	#teleports asteroids to side walls when trying to go out of bounds

func explode():
	emit_signal("exploded", global_position, size, points)
	queue_free()


func _on_body_entered(body):
	if body is Player:
		var player = body
		player.die()
