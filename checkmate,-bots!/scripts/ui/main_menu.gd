extends Control

@onready var options_panel: Control = $OptionsPanel
@onready var sfx_slider: HSlider = $OptionsPanel/VBoxContainer/SFX/HSlider
@onready var bgm_slider: HSlider = $OptionsPanel/VBoxContainer/BGM/HSlider


func _ready() -> void:
	if SoundManager:
		SoundManager.play_menu_music()
	_connect_button_sounds()
	_sync_sliders_from_settings()


func _process(delta: float) -> void:
	pass


func _on_play_pressed() -> void:
	if SoundManager:
		SoundManager.play_game_music()
	get_tree().change_scene_to_file("res://scenes/main/intro_cutscene.tscn")


func _on_options_pressed() -> void:
	_show_options(true)


func _on_how_to_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main/how_to_play.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()


func _connect_button_sounds() -> void:
	if SoundManager:
		(
			SoundManager
			. connect_button_sounds(
				[
					$"VBoxContainer/Play",
					$"VBoxContainer/Options",
					$"VBoxContainer/How to play",
					$"VBoxContainer/Exit",
					$"OptionsPanel/VBoxContainer/Close",
				]
			)
		)
		return

	var buttons := [
		$"VBoxContainer/Play",
		$"VBoxContainer/Options",
		$"VBoxContainer/How to play",
		$"VBoxContainer/Exit",
		$"OptionsPanel/VBoxContainer/Close",
	]

	for button in buttons:
		if not button:
			continue
		button.mouse_entered.connect(_on_button_hover)
		button.pressed.connect(_on_button_press)


func _on_button_hover():
	if SoundManager:
		SoundManager.play_button_hover()


func _on_button_press():
	if SoundManager:
		SoundManager.play_button_press()


func _on_sfx_slider_changed(value: float) -> void:
	if SoundManager:
		SoundManager.set_sfx_volume_db(value)


func _on_bgm_slider_changed(value: float) -> void:
	if SoundManager:
		SoundManager.set_music_volume_db(value)


func _on_close_options_pressed() -> void:
	_show_options(false)


func _show_options(show: bool) -> void:
	if options_panel:
		options_panel.visible = show
	if show:
		_sync_sliders_from_settings()


func _sync_sliders_from_settings() -> void:
	if not SoundManager:
		return

	if sfx_slider:
		sfx_slider.value = SoundManager.get_sfx_volume_db()
	if bgm_slider:
		bgm_slider.value = SoundManager.get_music_volume_db()
