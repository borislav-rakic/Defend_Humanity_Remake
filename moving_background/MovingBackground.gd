extends CanvasLayer

var speed = 50
var velocity = Vector2(-1, 0)
var original_position = offset.x

func _process(delta):
	offset.x += velocity.x * speed * delta
	
	if offset.x <= original_position - 1024:
		offset.x = original_position
