extends CanvasLayer

signal game_started
signal return_to_home
signal play_again

func _on_Start_pressed():
	emit_signal("game_started")

func _on_HomeButton_pressed():
	emit_signal("return_to_home")

func _on_PlayAgainButton_pressed():
	emit_signal("play_again")
