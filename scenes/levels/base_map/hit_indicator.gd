extends Node3D

@onready var map: DuckMap = %conductor.map

var lane_rotations = []
var focused_lane: int = 0: # 0-indexed, circular
	set(value):
		if value < 0: focused_lane = map.lane_count + value
		elif value > map.lane_count - 1: focused_lane = value - map.lane_count
		else: focused_lane = value
var snapThreshold: float = 0.001

func _ready():
	spawn_indicator()

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
		lane.size = Vector3(2.35 * sin(PI / map.lane_count), 0.05, 0.05)
		lane.rotation.z = i * (2 * PI / map.lane_count)
		lane_rotations.append(lane.rotation.z)
		lane.position.y = -1
		lane.position = lane.position.rotated(Vector3.BACK, i * (2 * PI / map.lane_count))
		add_child(lane)

func _input(event):
	if event.is_action_pressed("left"):
		focused_lane += 1
	if event.is_action_pressed("right"):
		focused_lane -= 1
	if event.is_action_pressed("flip"):
		focused_lane += 3
