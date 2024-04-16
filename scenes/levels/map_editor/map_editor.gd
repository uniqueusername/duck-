extends VBoxContainer

# editor data
@export var file_selector: FileDialog # file save/open dialog
@onready var lanes = {} # map each lane to its checkboxes
var hidden_lanes = {} # cache "deleted" lanes
var lane_count: int

# beatmap
@export var map: DuckMap = DuckMap.new()

func _ready():
	initialize_editor()

# generate ui according to map metadata
func initialize_editor():
	# clear existing lanes
	for lane in lanes.keys():
		lane.queue_free()
	for lane in hidden_lanes.keys():
		lane.queue_free()
	lanes.clear()
	hidden_lanes.clear()
	
	# create new lanes
	lane_count = map.lane_count
	$lane_count/counter.text = str(lane_count)
	for i in range(lane_count):
		create_empty_lane(i+1)

# reload the editor with a new number of lanes
# `lane_delta` is the number of lanes added or removed
func adjust_lane_count(lane_delta: int):
	if lane_count + lane_delta < 4: return
	
	if lane_delta < 0:
		for i in range(abs(lane_delta)):
			var curr_lane = lanes.keys()[lanes.keys().size()+(lane_delta+i)]
			hidden_lanes[curr_lane] = lanes[curr_lane]
			curr_lane.visible = false
			lanes.erase(curr_lane)
			lane_count -= 1
	else:
		var remaining_lanes = lane_delta
		while hidden_lanes.size() > 0 and remaining_lanes > 0:
			var curr_lane = hidden_lanes.keys()[hidden_lanes.keys().size()-1]
			lanes[curr_lane] = hidden_lanes[curr_lane]
			hidden_lanes.erase(curr_lane)
			curr_lane.visible = true
			lane_count += 1
			remaining_lanes -= 1
		while remaining_lanes > 0:
			create_empty_lane(lane_count)
			lane_count += 1
			remaining_lanes -= 1
	
	$lane_count/counter.text = str(lane_count)

# creates a new lane labeled `lane${num}` WITHOUT updating `lane_count`
func create_empty_lane(num: int):
	var new_lane = HBoxContainer.new()
	new_lane.name = "lane" + str(num)
	lanes[new_lane] = []
	$lanes.add_child(new_lane)
	
	for line in range(map.total_lines):
		if line % map.lines_per_beat == 0 and line > 0: new_lane.add_child(VSeparator.new())
		var checkbox = CheckBox.new()
		new_lane.add_child(checkbox)
		lanes[new_lane].append(checkbox)

# load a map from file
func load_map(path: String):
	map = load(path)
	map.size_to_song()
	initialize_editor()
	
	for i in range(lanes.keys().size()):
		var boxes = lanes[lanes.keys()[i]]
		for j in range(boxes.size()):
			boxes[j].button_pressed = map.get_bit(i, j)

# save current editor state to a file
func save_map(path: String):
	map.reset_bitmap()
	map.resize_map(lane_count, map.total_lines)
	
	for i in range(lanes.keys().size()):
		var boxes = lanes.get(lanes.keys()[i])
		for j in range(boxes.size()):
			map.set_bit(i, j, boxes[j].button_pressed)
	
	ResourceSaver.save(map, path)

func _on_save_pressed():
	file_selector.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	file_selector.show()

func _on_load_pressed():
	file_selector.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_selector.show()

func _on_file_selected(path):
	if file_selector.file_mode == FileDialog.FILE_MODE_SAVE_FILE:
		save_map(path)
	elif file_selector.file_mode == FileDialog.FILE_MODE_OPEN_FILE:
		load_map(path)
	
	file_selector.hide()

func _on_minus_pressed():
	adjust_lane_count(-2)

func _on_plus_pressed():
	adjust_lane_count(2)
