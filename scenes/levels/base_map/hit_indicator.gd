extends Node3D

@onready var map: DuckMap = %conductor.map

func _ready():
	spawn_indicator()

# configure rotation markers and display indicator
func spawn_indicator():
	for i in range(map.lane_count):
		var lane = CSGBox3D.new()
		lane.name = "lane" + str(i+1)
		lane.size = Vector3(2.35 * sin(PI / map.lane_count), 0.05, 0.05)
		lane.rotation.z = i * (2 * PI / map.lane_count)
		lane.position.y = -1
		lane.position = lane.position.rotated(Vector3.BACK, i * (2 * PI / map.lane_count))
		add_child(lane)
