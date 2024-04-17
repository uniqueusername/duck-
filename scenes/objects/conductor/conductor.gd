extends AudioStreamPlayer3D

signal new_line

# song metadata
@export var map: DuckMap = DuckMap.new()
var seconds_per_beat: float = 60.0 / map.bpm # seconds per beat

# runtime information
var current_beat: int = 0
var current_line: int = 0

# conductor configuration
@export var metronome: bool = false ## Play a tick every beat.

func _ready():
	stream = map.song
	play()

func _process(delta):
	var time: float = (get_playback_position()
		+ AudioServer.get_time_since_last_mix()
		- AudioServer.get_output_latency())
	
	var new_beat: int = int(time / seconds_per_beat)
	var new_line: int = int(time / seconds_per_beat * map.lines_per_beat)
	if current_line != new_line:
		current_line = new_line
		line()
	if current_beat != new_beat:
		current_beat = new_beat
		beat()

func beat():
	if metronome: $metronome.play()

func line():
	pass
