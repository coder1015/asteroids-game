extends Control

@onready var score_label: Label = $Score

var score: int = 0:
	set(value):
		score_label.text = "SCORE: " + str(value)

var uilife_scene = preload("res://scenes/ui_life.tscn")

@onready var lives = $HBoxContainer

func init_lives(amount):
	for ul in lives.get_children():
		ul.queue_free()
	for i in amount:
		var ul = uilife_scene.instantiate()
		lives.add_child(ul)
