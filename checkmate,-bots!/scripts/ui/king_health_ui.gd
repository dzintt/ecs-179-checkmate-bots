extends MarginContainer

@onready var bar: ProgressBar = $VBoxContainer/ProgressBar

var _current_health: int = 0
var _max_health: int = 0


func _ready():
	if EventBus:
		EventBus.king_damaged.connect(_on_king_damaged)

	_update_ui()


func initialize(current_health: int, max_health: int):
	_current_health = current_health
	_max_health = max_health
	_update_ui()


func _on_king_damaged(current_health: int, max_health: int):
	_current_health = current_health
	_max_health = max_health
	_update_ui()


func _update_ui():
	if _max_health <= 0:
		return

	var clamped = clampi(_current_health, 0, _max_health)

	if bar:
		bar.max_value = _max_health
		bar.value = clamped
