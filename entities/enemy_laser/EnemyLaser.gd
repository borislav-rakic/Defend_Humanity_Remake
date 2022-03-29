extends Area2D

export var speed = 1000
var velocity = Vector2(-1, 0)

func _physics_process(delta):
	position.x += velocity.x * speed * delta

# As soon as the laser exits the screen, it is deleted
func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
