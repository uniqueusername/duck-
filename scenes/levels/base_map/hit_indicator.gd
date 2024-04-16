extends Node3D

@onready var map: DuckMap = %conductor.map

func _ready():
	spawn_indicator()

func spawn_indicator():
	for i in range(map.lane_count):
		var lane = CSGBox3D.new()
		lane.size = Vector3(2 * sin(PI / map.lane_count), 0.1, 0.1)
		lane.rotation.z = i * (2 * PI / map.lane_count)
		lane.position.y = -1
		lane.position = lane.position.rotated(Vector3.BACK, i * (2 * PI / map.lane_count))
		add_child(lane)
