extends Node

## Simple centralized sound manager for one-shot effects
@export var placement_sound: AudioStream = preload("res://assets/sound effects/tower_placement.mp3")
@export var enemy_hit_sound: AudioStream = preload("res://assets/sound effects/metal_clang.mp3")


func _ready():
	_connect_signals()


func _connect_signals():
	if not Engine.is_editor_hint():
		EventBus.tower_placed.connect(_on_tower_placed)
		EventBus.enemy_hit.connect(_on_enemy_hit)


func _on_tower_placed(_tower: Node, _position: Vector2, _cost: int):
	_play_sound(placement_sound)


func _on_enemy_hit(_enemy: Node, _damage: float):
	_play_sound(enemy_hit_sound)


func _play_sound(stream: AudioStream):
	if stream == null:
		return

	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.bus = "Master"
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()
