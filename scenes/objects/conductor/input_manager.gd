extends Node

signal left
signal right
signal flip

func _input(event):
	if event.is_action_pressed("left"):
		left.emit()
	elif event.is_action_pressed("right"):
		right.emit()
	elif event.is_action_pressed("flip"):
		flip.emit()
