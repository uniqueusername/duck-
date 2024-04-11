extends VBoxContainer

@onready var lanes = [$lane1, $lane2, $lane3, $lane4, $lane5, $lane6]
var map: BitMap = BitMap.new()

var map_path: String = "assets/maps/tension.tres"
var lines: int = 24

func _ready():
	initialize_map()
	if FileAccess.file_exists(map_path): load_map(map_path)

func initialize_map():
	for i in lanes.size():
		for j in range(lines):
			lanes[i].add_child(CheckBox.new())
	
	map.create(Vector2i(6, lines))

func load_map(path: String):
	map = load(path)
	
	for i in range(map.get_size().x):
		for j in range(map.get_size().y):
			lanes[i].get_children()[j].button_pressed = map.get_bit(i, j)

func save_map(path: String):
	for i in range(lanes.size()):
		var bits = lanes[i].get_children()
		for j in range(bits.size()):
			map.set_bit(i, j, bits[j].button_pressed)
			
	ResourceSaver.save(map, path)

func _on_save_pressed():
	save_map(map_path)
