extends Area2D

signal wrench_collected

var velocity = Vector2(-1, 0)
var speed
var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	speed = rng.randi_range(50, 150)

# Moves the item to the left with a random speed
func _physics_process(delta):
	position.x += velocity.x * speed * delta

# When the player hits the item it is collected
func _on_Life_body_entered(body):
	emit_signal("wrench_collected")
	queue_free()

# When the item leaves the screen, it is deleted
func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
