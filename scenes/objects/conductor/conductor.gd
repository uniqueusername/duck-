extends AudioStreamPlayer3D

# song metadata
var bpm: float = stream.bpm if stream.bpm != 0 else 120 # beats per minute
var spb: float = 60.0 / bpm # seconds per beat

# runtime information
var current_beat: int = 0

func _ready():
	play()

func _process(delta):
	var time = (get_playback_position()
		+ AudioServer.get_time_since_last_mix()
		- AudioServer.get_output_latency())
	
	var new_beat = int(time / spb)
	if current_beat != new_beat:
		current_beat = new_beat
		$metronome.play()
