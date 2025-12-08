extends CanvasLayer

@onready var start_wave_button: Button = $WaveControl/StartWaveButton


func _ready():
	_connect_signals()
	_refresh_button_state()


func _connect_signals():
	if EventBus:
		EventBus.wave_started.connect(_on_wave_started)
		EventBus.wave_completed.connect(_on_wave_completed)
		EventBus.all_waves_completed.connect(_on_all_waves_completed)

	if start_wave_button:
		start_wave_button.pressed.connect(_on_start_wave_pressed)


func _on_start_wave_pressed():
	if WaveManager == null:
		return
	if WaveManager.is_wave_active():
		return
	if WaveManager.get_current_wave() >= WaveManager.max_waves:
		return

	start_wave_button.disabled = true
	start_wave_button.text = _in_progress_text()
	WaveManager.start_wave()


func _on_wave_started(_wave_number: int):
	_refresh_button_state()


func _on_wave_completed(_wave_number: int):
	_refresh_button_state()


func _on_all_waves_completed():
	_refresh_button_state()


func _refresh_button_state():
	if start_wave_button == null:
		return
	if WaveManager == null:
		start_wave_button.disabled = true
		start_wave_button.text = "Start Wave"
		return

	if WaveManager.is_wave_active():
		start_wave_button.disabled = true
		start_wave_button.text = _in_progress_text()
		return

	var current_wave := WaveManager.get_current_wave()
	var max_waves := WaveManager.max_waves

	if current_wave >= max_waves:
		start_wave_button.visible = false
		return

	start_wave_button.visible = true
	start_wave_button.disabled = false
	start_wave_button.text = "Start Wave %d/%d" % [current_wave + 1, max_waves]


func _in_progress_text() -> String:
	return "Wave %d in progress..." % WaveManager.get_current_wave()
