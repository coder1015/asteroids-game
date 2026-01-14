extends Node2D

@onready var lasers = $Lasers
@onready var player = $Player
@onready var asteroids = $Asteroids
@onready var hud = $UI/HUD
@onready var player_spawn_pos = $PlayerSpawnPOS
@onready var game_over_screen = $UI/GameOverScreen
@onready var player_spawn_area = $PlayerSpawnPOS/PlayerSpawnArea



var asteroid_scene = preload("res://scenes/asteroid.tscn")

var score:= 0:
	set(value):
		score = value
		hud.score = score

var _lives = 3

var lives:
	set(value):
		_lives = value
		hud.init_lives(_lives)
	get:
		return _lives
#uses different variable as a backup to avoid recursion


func _ready():
	game_over_screen.visible = false
	score = 0
	lives = 3
	player.connect("laser_shot", _on_player_laser_shot)
	player.connect("died", _on_player_died)
	spawn_loop()
	for asteroid in asteroids.get_children():
			asteroid.connect("exploded", _on_asteroid_exploded)

func _process(delta):
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
		#resets the game by reloading scene

func _on_player_laser_shot(laser):
	$LaserSound.play()
	lasers.add_child(laser)
func _on_asteroid_exploded(pos, size, points):
	score += points
	for i in range(2):
		match size:
			Asteroid.AsteroidSize.LARGE:
				spawn_asteroid(pos, Asteroid.AsteroidSize.MEDIUM)
				
			Asteroid.AsteroidSize.MEDIUM:
				spawn_asteroid(pos, Asteroid.AsteroidSize.SMALL)
			Asteroid.AsteroidSize.SMALL:
				pass

func spawn_asteroid(pos, size):
	var a = asteroid_scene.instantiate()
	a.global_position = pos
	a.size = size
	a.connect("exploded", _on_asteroid_exploded)
	asteroids.call_deferred("add_child", a)
	#avoids errors in debugger

func _on_player_died():
	lives -= 1;
	if lives <= 0:
		await get_tree().create_timer(2).timeout
		$LossSound.play()
		game_over_screen.visible = true
	else:
		await get_tree().create_timer(1).timeout
		while player_spawn_area.has_overlapping_bodies():
			await get_tree().create_timer(0.1).timeout
			$LossSound.play()
		player.respawn(player_spawn_pos.global_position)

func spawn_loop():
	while lives > 0:
		spawn_asteroid(Vector2(randf_range(0, get_viewport_rect().size.x), -40),Asteroid.AsteroidSize.LARGE)
		await get_tree().create_timer(randf_range(0,2)).timeout
		
