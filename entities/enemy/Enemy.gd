extends Area2D

signal enemy_eliminated

export (PackedScene) var Explosion

var speed = 100
var velocity = Vector2()
var spawn_speed = 2000
var lives = 3
var screen_size
var spawn_velocity = Vector2(-1, 0)
var invincibility = false
var explosion_has_happened = false

func _ready():
	$Default.playing = true
	screen_size = get_viewport_rect().size
	get_parent().connect("level_2_reached", self, "level_2")

func _process(delta):
	position.x += velocity.x * delta
	position.y += velocity.y * delta
	position.x = clamp(position.x, screen_size.x / 2, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)

# This handles the spawn animation
func _physics_process(delta):
	position.x += spawn_velocity.x * spawn_speed * delta

func level_2():
	$Default.animation = "level_2"
	lives = 5

# Checks wether the laser entered the hitbox of the enemy
func _on_Enemy_area_entered(area):
	if !invincibility:
		if lives > 1:
			lives -= 1
		else:
			if !explosion_has_happened:
				enemy_explosion()
				emit_signal("enemy_eliminated")
		area.queue_free()
		enemy_blinking()

# Starts the explosion animation
func enemy_explosion():
	explosion_has_happened = true
	$Movement.stop()
	velocity = Vector2()
	$Default.visible = false
	$Explosion.visible = true
	$Explosion.playing = true
	$ExplosionSound.playing = true

# Makes the enemy blink when hit
func enemy_blinking():
	if !$Explosion.visible:
		invincibility = true
		var t1 = Timer.new()
		t1.set_wait_time(0.2)
		t1.set_one_shot(true)
		self.add_child(t1)
		
		for i in 3:
			hide()
			t1.start()
			yield(t1, "timeout")
			show()
			if i < 2:
				t1.start()
				yield(t1, "timeout")
		
		invincibility = false

# As soon as the enemy enters the screen, the spawn animation is stopped
func _on_Enemy_entered_screen():
	var t2 = Timer.new()
	t2.set_wait_time(0.15)
	t2.set_one_shot(true)
	self.add_child(t2)
	t2.start()
	yield(t2, "timeout")
	set_physics_process(false)

# As soon as the explosion animation is finished, the enemy instance is deleted
func _on_explosion_animation_finished():
	queue_free()

# Picks a random path for the enemy
func _on_Movement_timeout():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var path = rng.randi_range(0, 8)
	velocity = Vector2()
	
	if path == 0:
		velocity = Vector2()
	if path == 1:
		if position.y > 100:
			velocity.y -= 1
		else:
			velocity.y += 1
	elif path == 2:
		if position.y > 100 || position.x < screen_size.x - 100:
			velocity.y -= 1
			velocity.x += 1
		else:
			velocity.y += 1
			velocity.x -= 1
	elif path == 3:
		if position.x < screen_size.x - 100:
			velocity.x += 1
		else:
			velocity.x -= 1
	elif path == 4:
		if position.x < screen_size.x - 100 || position.y < screen_size.y - 100:
			velocity.x += 1
			velocity.y += 1
		else:
			velocity.x -= 1
			velocity.y -= 1
	elif path == 5:
		if position.y < screen_size.y - 100:
			velocity.y += 1
		else:
			velocity.y -= 1
	elif path == 6:
		if position.y < screen_size.y - 100 || position.x > screen_size.x / 2 + 100:
			velocity.y += 1
			velocity.x -= 1
		else:
			velocity.y -= 1
			velocity.x += 1
	elif path == 7:
		if position.x > screen_size.x / 2 + 100:
			velocity.x -= 1
		else:
			velocity.x += 1
	elif path == 8:
		if position.x > screen_size.x / 2 + 100 || position.y > 100:
			velocity.x -= 1
			velocity.y -= 1
		else:
			velocity.x += 1
			velocity.y += 1
	
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
