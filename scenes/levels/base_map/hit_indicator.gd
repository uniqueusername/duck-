extends Node3D

# references
@onready var map: DuckMap = %conductor.map
var note_scene: PackedScene = preload("res://scenes/objects/note/note.tscn")
var lanes = []

# variables
var lane_rotations = []
var focused_lane: int = 0: # 0-indexed, circular
	set(value):
		if value < 0: focused_lane = map.lane_count + value
		elif value > map.lane_count - 1: focused_lane = value - map.lane_count
		else: focused_lane = value
var snapThreshold: float = 0.001

func _ready():
	spawn_indicator()
	spawn_notes()

func _process(delta):
	# rotation machine
	if (abs(rotation.z - lane_rotations[focused_lane]) < snapThreshold):
		rotation.z = lane_rotations[focused_lane]
	else:
		rotation.z = lerp_angle(rotation.z, lane_rotations[focused_lane], 0.2)

# configure rotation markers and display indicator
func spawn_indicator():
	for i in range(map.lane_count):
		var lane = CSGBox3D.new()
		lanes.append(lane)
		lane.name = "lane" + str(i+1)
		lane.size = Vector3(2.35 * sin(PI / map.lane_count), 0.05, 0.05)
		lane.rotation.z = i * (2 * PI / map.lane_count)
		lane_rotations.append(lane.rotation.z)
		lane.position.y = -1
		lane.position = lane.position.rotated(Vector3.BACK, i * (2 * PI / map.lane_count))
		add_child(lane)

func spawn_notes():
	for line in range(map.total_lines):
		for lane in range(map.lane_count):
			if map.get_bit(lane, line):
				var note = note_scene.instantiate()
				note.position.z = -1 * line - 0.5
				lanes[lane].add_child(note)

func _input(event):
	if event.is_action_pressed("left"):
		focused_lane += 1
	if event.is_action_pressed("right"):
		focused_lane -= 1
	if event.is_action_pressed("flip"):
		focused_lane += 3
