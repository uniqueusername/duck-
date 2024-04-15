extends VBoxContainer

@export var file_selector: FileDialog
@onready var lanes = [$lane1, $lane2, $lane3, $lane4, $lane5, $lane6]
var map: BitMap = BitMap.new()

var lines: int = 24

func _ready():
	initialize_map()

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
