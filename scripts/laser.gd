extends Area2D

@export var speed := 500.0

var movement_vector := Vector2(0, -1)

func _physics_process(delta):
		global_position += movement_vector.rotated(rotation) * speed * delta
		#position increases by movement vector in same rotation as ship

func _on_visible_on_screen_notifer_2d_screen_exited():
	#print("deleting " + name)
	queue_free()


func _on_area_entered(area):
	if area is Asteroid:
		var asteroid = area
		asteroid.explode()
		queue_free()
		#uses signal to check if asteroid comes in contact
