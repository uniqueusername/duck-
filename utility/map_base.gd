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
	if bitmap.get_true_bit_count() == 0: reset_bitmap()
	else: size_to_song()

func set_bit(x: int, y: int, state: bool):
	bitmap.set_bit(x, y, state)

func get_bit(x: int, y: int) -> bool:
	return bitmap.get_bit(x, y)

func reset_bitmap():
	if song:
		bpm = song.bpm
		total_beats = int(ceil(song.get_length() / 60 * bpm))
	else: total_beats = 8
	
	total_lines = total_beats * lines_per_beat
	bitmap.create(Vector2i(lane_count, total_lines))

func size_to_song():
	resize_map(lane_count, lines_per_beat * int(ceil(song.get_length() / 60 * bpm)))

# attempts to resize the map as non-destructively as possible
func resize_map(lanes: int, lines: int):
	var new_map: BitMap = BitMap.new()
	new_map.create(Vector2i(lanes, lines))
	
	var min_lanes = min(lanes, lane_count)
	var min_lines = min(lines, total_lines)
	
	for x in range(min_lanes):
		for y in range(min_lines):
			new_map.set_bit(x, y, bitmap.get_bit(x, y))
	
	lane_count = lanes
	total_lines = lines
	bitmap = new_map
