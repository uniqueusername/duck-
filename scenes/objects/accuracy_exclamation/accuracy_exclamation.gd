extends Label

var alpha_tick: float = 0.5
var movement_tick: float = 25

func _process(delta):
	var temp = modulate.a
	temp -= alpha_tick * delta
	if temp < 0: queue_free()
	
	modulate.a -= alpha_tick * delta
	position.y += movement_tick * delta
