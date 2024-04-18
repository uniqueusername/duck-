extends Node3D

# references
@onready var map: DuckMap = %conductor.map
var note_scene: PackedScene = preload("res://scenes/objects/note/note.tscn")
var exclamation_scene: PackedScene = preload("res://scenes/objects/accuracy_exclamation/accuracy_exclamation.tscn")
var lanes = []
var tween: Tween

# variables
var lane_rotations = []
var focused_lane: int = 0: # 0-indexed, circular
	set(value):
		if value < 0: focused_lane = map.lane_count + value
		elif value > map.lane_count - 1: focused_lane = value - map.lane_count
		else: focused_lane = value
@onready var lines_per_second: float = map.lines_per_beat / %conductor.seconds_per_beat
@onready var active_lanes_array = map.get_active_lanes_array()

# gameplay stuff
var health: float = 100:
	set(value):
		if value > 100: health = 100
		else: health = value
		$health.text = str(health)
var accuracy_margin: float = 0.2 # how many seconds before a note is missed
@onready var listener_starts = map.lane_changes
var listeners = []

func _ready():
	create_lanes()
	spawn_notes()
	config_listeners()
	
	%conductor._line.connect(sync_notes)
	%conductor._line.connect(check_active_lane)

func _process(delta):
	$lanes.position.z += lines_per_second * delta
	
	if listener_starts.size() > 0 and %conductor.time > listener_starts[0]:
		listeners.append(accuracy_margin)
		listener_starts.remove_at(0)
		
	for i in range(listeners.size()):
		if i >= listeners.size(): break
		listeners[i] -= delta
		if listeners[i] < -accuracy_margin:
			listeners.remove_at(i)
			var exclamation = exclamation_scene.instantiate()
			exclamation.text = "miss"
			add_child(exclamation)
			health -= 25

# configure rotation markers and display indicator
func create_lanes():
	for i in range(map.lane_count):
		var lane = Node3D.new()
		lanes.append(lane)
		lane.name = "lane" + str(i+1)
		lane.rotation.z = i * (2 * PI / map.lane_count)
		lane_rotations.append(lane.rotation.z)
		lane.position.y = -1
		lane.position = lane.position.rotated(Vector3.BACK, lane.rotation.z)
		$lanes.add_child(lane)

func spawn_notes():
	for line in range(map.total_lines):
		for lane in range(map.lane_count):
			if map.get_bit(lane, line):
				var note = note_scene.instantiate()
				note.position.z = -1 * line - 0.5
				lanes[lane].add_child(note)

# get song state from conductor and force alignment
func sync_notes(current_line: int):
	$lanes.position.z = current_line

# modify health based on if we are in an active lane or not
func check_active_lane(current_line: int):
	var check_lane: int = 0 if focused_lane == 0 else 6 - focused_lane
	if not active_lanes_array[current_line].has(check_lane):
		health -= 5

func config_listeners():
	for i in range(listener_starts.size()):
		listener_starts[i] -= accuracy_margin

# set up tween for rotation
func do_rotation(angle: float):
	tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	var new_angle: float = lerp_angle(rotation.z, angle, 1)
	tween.tween_property(self, "rotation", Vector3(0, 0, new_angle), 0.1)

func _input(event):
	if event.is_action_pressed("left"):
		focused_lane += 1
	if event.is_action_pressed("right"):
		focused_lane -= 1
	if event.is_action_pressed("flip"):
		focused_lane += 3
	
	if listeners.size() > 0:
		var accuracy = listeners[0]
		listeners.remove_at(0)
		
		var exclamation = exclamation_scene.instantiate()
		if abs(accuracy) < 0.5 * accuracy_margin:
			exclamation.text = "perfect"
			health += 10
		else:
			exclamation.text = "bad"
			health += 3
		add_child(exclamation)
		
	do_rotation(lane_rotations[focused_lane])
