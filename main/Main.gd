extends Node

signal game_started
signal level_2_reached

export (PackedScene) var Enemy
export (PackedScene) var Laser
export (PackedScene) var Explosion
export (PackedScene) var EnemyLaser
export (PackedScene) var Life
var score = 0
var shoot_enabled = true
var enemy1_shoot_enabled = false
var enemy2_shoot_enabled = false
var enemies
var player_spawn_speed = 50
var screen_size
var animation_speed = 1
var player_lives = 4
var level_2_reached = false
var game_ongoing = false

var life_meter4 = preload("res://assets/lifeMeter (rounded).png")
var life_meter3 = preload("res://assets/lifeMeter3 (rounded).png")
var life_meter2 = preload("res://assets/lifeMeter2 (rounded).png")
var life_meter1 = preload("res://assets/lifeMeter1 (rounded).png")

var enemy_lvl_2_0 = preload("res://assets/Alien Ship v4 l2 animated-1.png")
var enemy_lvl_2_1 = preload("res://assets/Alien Ship v4 l2 animated-2.png")

func game_started():
	$SpawnLifeTimer.start()
	game_ongoing = true
	score = 0
	emit_signal("game_started")
	$Player/PlayerStartAnimation.current_animation = "player_start_animation"
	$Player/PlayerStartAnimation.play()
	$MenuTheme.playing = false
	$MainThemeIntro.playing = true
	$HUD/Title.visible = false
	$HUD/Start.visible = false
	var t = Timer.new()
	add_child(t)
	t.set_wait_time(5.56)
	t.set_one_shot(true)
	t.start()
	yield(t, "timeout")
	$MainThemeIntro.playing = false
	$MainTheme.playing = true
	$HUD/Lifemeter.visible = true
	$Enemy1LaserCooldown.start()
	$Enemy2LaserCooldown.start()
	spawn_enemy()
	spawn_enemy()
	set_process(true)

func game_over():
	$SpawnLifeTimer.stop()
	game_ongoing = false
	level_2_reached = false
	set_process(false)
	var enemies = get_tree().get_nodes_in_group("enemies")
	enemies[0].queue_free()
	enemies[1].queue_free()
	$HUD/Lifemeter.visible = false
	$MainTheme.playing = false
	$Deathsound.playing = true
	var t = Timer.new()
	add_child(t)
	t.set_wait_time(2.3)
	t.set_one_shot(true)
	t.start()
	yield(t, "timeout")
	$Deathsound.playing = false
	$DeathScreenTheme.playing = true
	$HUD/GameOver.visible = true
	$HUD/Score.visible = true
	$HUD/Score.text = "Your Score: %s" % score
	$HUD/HomeButton.visible = true
	$HUD/PlayAgainButton.visible = true

func play_again():
	$SpawnLifeTimer.start()
	game_ongoing = true
	score = 0
	$HUD/Score.visible = false
	$HUD/GameOver.visible = false
	$HUD/HomeButton.visible = false
	$HUD/PlayAgainButton.visible = false
	$DeathScreenTheme.playing = false
	$Player.position.x = screen_size.x / 4
	$Player.position.y = screen_size.y / 2
	$MainTheme.playing = true
	$Player/Explosion.visible = false
	$Player/Default.visible = true
	$Player.lives = 4
	player_lives = 4
	enemy1_shoot_enabled = false
	enemy2_shoot_enabled = false
	$Enemy1LaserCooldown.start()
	$Enemy2LaserCooldown.start()
	spawn_enemy()
	spawn_enemy()
	set_process(true)
	$HUD/Lifemeter.visible = true
	$HUD/Lifemeter.texture = life_meter4

func return_to_home():
	$HUD/Score.visible = false
	$HUD/GameOver.visible = false
	$HUD/HomeButton.visible = false
	$HUD/PlayAgainButton.visible = false
	$DeathScreenTheme.playing = false
	$Player.position.x = screen_size.x / 2
	$Player.position.y = screen_size.y - screen_size.y / 4
	$Player/Explosion.visible = false
	$Player/Default.visible = true
	$HUD/Title.visible = true
	$HUD/Start.visible = true
	$MenuTheme.playing = true
	$HUD/Lifemeter.texture = life_meter4
	$Player.lives = 4
	player_lives = 4
	enemy1_shoot_enabled = false
	enemy2_shoot_enabled = false

func _ready():
	set_process(false)
	screen_size = get_viewport().size
	randomize()
	$MenuTheme.playing = true

func _process(delta):
	if get_tree().get_nodes_in_group("enemies").size() < 2:
		spawn_enemy()
	
	if Input.is_action_pressed("ui_select") && shoot_enabled:
		player_shoot()
	
	enemies = get_tree().get_nodes_in_group("enemies")
	
	enemies[0].connect("enemy_eliminated", self, "disable_enemy1_shoot")
	
	enemies[1].connect("enemy_eliminated", self, "disable_enemy2_shoot")
	
	if ((enemies[0].position.y + 14 > $Player.position.y - 50 && enemies[0].position.y + 14 < $Player.position.y + 50) && enemy1_shoot_enabled):
		enemy1_shoot(enemies[0])
	
	if ((enemies[1].position.y + 14 > $Player.position.y - 50 && enemies[1].position.y + 14 < $Player.position.y + 50) && enemy2_shoot_enabled):
		enemy2_shoot(enemies[1])

func enemy1_shoot(enemy):
	enemy1_shoot_enabled = false
	$Enemy1LaserCooldown.start()
	$LaserSound.play()
	var enemy_laser = EnemyLaser.instance()
	add_child(enemy_laser)
	enemy_laser.position.x = enemy.position.x - 62
	enemy_laser.position.y = enemy.position.y + 14

func enemy2_shoot(enemy):
	enemy2_shoot_enabled = false
	$Enemy2LaserCooldown.start()
	$LaserSound.play()
	var enemy_laser = EnemyLaser.instance()
	add_child(enemy_laser)
	enemy_laser.position.x = enemy.position.x - 62
	enemy_laser.position.y = enemy.position.y + 14

func disable_enemy1_shoot():
	enemy1_shoot_enabled = false
	$Enemy1LaserCooldown.start()
	if level_2_reached:
		score += 250
	else:
		score += 100
	if score >= 2500:
		level_2_reached = true

func disable_enemy2_shoot():
	enemy2_shoot_enabled = false
	$Enemy2LaserCooldown.start()
	if level_2_reached:
		score += 250
	else:
		score += 100
	if score >= 2500:
		level_2_reached = true

func enable_enemy1_shoot():
	enemy1_shoot_enabled = true

func enable_enemy2_shoot():
	enemy2_shoot_enabled = true

func spawn_enemy():
	# Random spawn location for the enemy
	var enemy_spawn_location = $EnemySpawn/EnemySpawnLocation
	enemy_spawn_location.offset = randi()
	
	# Instance of an enemy is created
	var enemy = Enemy.instance()
	add_child(enemy)
	
	# Sets the enemy's position to a random location
	enemy.position = enemy_spawn_location.position
	
	if level_2_reached:
		emit_signal("level_2_reached")

func player_shoot():
	$LaserSound.playing = true
	var laser = Laser.instance()
	add_child(laser)
	laser.position.x = $Player.position.x + 50
	laser.position.y = $Player.position.y + 10
	$LaserCooldown.start()
	shoot_enabled = false

func enable_shoot_function():
	shoot_enabled = true

func change_lifemeter_texture():
	player_lives -= 1
	if player_lives == 3:
		$HUD/Lifemeter.set_texture(life_meter3)
	elif player_lives == 2:
		$HUD/Lifemeter.set_texture(life_meter2)
	elif player_lives == 1:
		$HUD/Lifemeter.set_texture(life_meter1)

func spawn_life():
	if player_lives <= 2 && game_ongoing:
		var life_spawn_location = $EnemySpawn/EnemySpawnLocation
		life_spawn_location.offset = randi()
		
		var life = Life.instance()
		add_child(life)
		
		life.position = life_spawn_location.position
		
		life.connect("wrench_collected", self, "increase_life")
	$SpawnLifeTimer.start()

func increase_life():
	if player_lives < 4:
		player_lives += 1
		$Player.lives += 1
	if player_lives == 2:
		$HUD/Lifemeter.texture = life_meter2
	elif player_lives == 3:
		$HUD/Lifemeter.texture = life_meter3
	elif player_lives == 4:
		$HUD/Lifemeter.texture = life_meter4
