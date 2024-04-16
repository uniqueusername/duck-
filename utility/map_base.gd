extends Resource
class_name DuckMap

@export var song: AudioStream

# map information
@export_subgroup("Map Information")
@export var lane_count: int = 6
@export var lines_per_beat: int = 4
var total_lines: int
@export var bitmap: BitMap = BitMap.new()

# song data
@export_subgroup("Song Data")
@export var bpm: int = 120
var total_beats: int

func _init():
	if song: total_beats = int(ceil(song.get_length() / 60 * bpm))
	else: total_beats = 8
	
	total_lines = total_beats * lines_per_beat
	bitmap.create(Vector2i(lane_count, total_lines))
	
func set_bit(x: int, y: int, state: bool):
	bitmap.set_bit(x, y, state)

func get_bit(x: int, y: int) -> bool:
	return bitmap.get_bit(x, y)
