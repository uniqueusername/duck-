extends AudioStreamPlayer3D

signal _line
signal _beat

# song metadata
@export var map: DuckMap = DuckMap.new()
@onready var seconds_per_beat: float = 60.0 / map.bpm # seconds per beat

# runtime information
var time: float = 0
var current_beat: int = 0
var current_line: int = 0

# conductor configuration
@export var metronome: bool = false ## Play a tick every beat.

func _ready():
	stream = map.song
	play()

func _process(_delta):
	time = (get_playback_position()
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
	_beat.emit(current_beat)

func line():
	_line.emit(current_line)
