extends Area2D

signal laser_shot
signal player_eliminated
signal life_lost

export var speed = 400
var velocity = Vector2()
var lives = 4
var screen_size
var invincibility = false
var explosion_has_happened = false

func _ready():
	set_process(false)
	screen_size = get_viewport_rect().size
	$Default.playing = true
	get_parent().connect("game_started", self, "start_game")
	position.x = screen_size.x / 2
	position.y = screen_size.y - screen_size.y / 4

func start_game():
	explosion_has_happened = false
	$Explosion.playing = false
	$Explosion.frame = 0
	var t = Timer.new()
	add_child(t)
	t.set_wait_time(5.56)
	t.set_one_shot(true)
	t.start()
	yield(t, "timeout")
	set_process(true)

func play_again():
	set_process(true)
	lives = 4
	explosion_has_happened = false
	$Explosion.playing = false
	$Explosion.frame = 1

func _process(delta):
	# Checks wether the player wants to move in a direction
	velocity = Vector2()
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
	
	position += velocity * delta
	
	position.x = clamp(position.x, 0, screen_size.x / 2 - 100)
	position.y = clamp(position.y, 0, screen_size.y)

# This function is called when the player was hit
func _on_Player_area_entered(area):
	if !invincibility:
		if lives > 1:
			lives -= 1
			emit_signal("life_lost")
		else:
			if !explosion_has_happened:
				player_explosion()
				emit_signal("player_eliminated")
		area.queue_free()
		player_blinking()

func player_explosion():
	set_process(false)
	explosion_has_happened = true
	velocity = Vector2()
	$Default.visible = false
	$Explosion.visible = true
	$Explosion.playing = true
	$ExplosionSound.playing = true

# This animates the hit animation for the player
func player_blinking():
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
