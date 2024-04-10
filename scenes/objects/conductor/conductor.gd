extends AudioStreamPlayer3D

var bpm: float = 120
var time: float = 0

func _ready():
	play()

func _process(delta):
	time -= (get_playback_position()
		+ AudioServer.get_time_since_last_mix()
		- AudioServer.get_output_latency())
