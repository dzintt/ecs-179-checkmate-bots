extends Node

## Simple centralized sound manager for one-shot effects and music
@export var placement_sound: AudioStream = preload("res://assets/sound effects/tower_placement.mp3")
@export var enemy_hit_sound: AudioStream = preload("res://assets/sound effects/metal_clang.mp3")
@export var button_hover_sound: AudioStream = preload("res://assets/sound effects/button_hover.mp3")
@export var illegal_move_sound: AudioStream = preload("res://assets/sound effects/illegal.mp3")
@export
var victory_sound: AudioStream = preload("res://assets/sound effects/medieval-fanfare-6826.mp3")
@export var defeat_sound: AudioStream = preload(
	"res://assets/sound effects/beated-by-a-computer-by-tromosm-281034.mp3"
)

# Background music
@export var menu_music: AudioStream = preload("res://assets/bgm/dearly.mp3")
@export var game_music: AudioStream = preload("res://assets/bgm/curious.mp3")
@export var music_bus := "Master"
@export_range(-30.0, 6.0, 0.5) var default_music_volume_db := 0.0
@export_range(-30.0, 6.0, 0.5) var default_sfx_volume_db := 0.0
const AUDIO_CONFIG_PATH := "user://audio_settings.cfg"

var _music_player: AudioStreamPlayer
var _music_volume_db := 0.0
var _sfx_volume_db := 0.0


func _ready():
	_init_music_player()
	_load_settings()
	_connect_signals()


func _connect_signals():
	if not Engine.is_editor_hint():
		EventBus.tower_placed.connect(_on_tower_placed)
		EventBus.enemy_hit.connect(_on_enemy_hit)


func _on_tower_placed(_tower: Node, _position: Vector2, _cost: int):
	_play_sound(placement_sound)


func _on_enemy_hit(_enemy: Node, _damage: float):
	_play_sound(enemy_hit_sound)


func play_button_hover():
	_play_sound(button_hover_sound)


func play_button_press():
	_play_sound(placement_sound)


func play_illegal_move():
	_play_sound(illegal_move_sound)


func play_victory():
	_play_sound(victory_sound)


func play_defeat():
	_play_sound(defeat_sound)


func _play_sound(stream: AudioStream):
	if stream == null:
		return

	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.bus = "Master"
	player.volume_db = _sfx_volume_db
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()


func play_menu_music():
	_play_music(menu_music)


func play_game_music():
	_play_music(game_music)


func stop_music():
	if _music_player:
		_music_player.stop()


func _play_music(stream: AudioStream):
	if stream == null:
		return

	if stream is AudioStreamOggVorbis:
		(stream as AudioStreamOggVorbis).loop = true
	elif stream is AudioStreamMP3:
		(stream as AudioStreamMP3).loop = true
	elif stream is AudioStreamWAV:
		(stream as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD

	_music_player.stream = stream
	_music_player.volume_db = _music_volume_db
	if not _music_player.playing:
		_music_player.play()
	else:
		_music_player.stop()
		_music_player.play()


func _init_music_player():
	if _music_player:
		return

	_music_player = AudioStreamPlayer.new()
	_music_player.bus = music_bus
	_music_player.autoplay = false
	_music_player.process_mode = Node.PROCESS_MODE_ALWAYS
	_music_player.volume_db = _music_volume_db
	add_child(_music_player)


func set_music_volume_db(db: float):
	_music_volume_db = clampf(db, -30.0, 6.0)
	if _music_player:
		_music_player.volume_db = _music_volume_db
	_save_settings()


func set_sfx_volume_db(db: float):
	_sfx_volume_db = clampf(db, -30.0, 6.0)
	_save_settings()


func get_music_volume_db() -> float:
	return _music_volume_db


func get_sfx_volume_db() -> float:
	return _sfx_volume_db


func _load_settings():
	_music_volume_db = default_music_volume_db
	_sfx_volume_db = default_sfx_volume_db

	var cfg := ConfigFile.new()
	var err = cfg.load(AUDIO_CONFIG_PATH)
	if err == OK:
		_music_volume_db = clampf(cfg.get_value("audio", "music_db", _music_volume_db), -30.0, 6.0)
		_sfx_volume_db = clampf(cfg.get_value("audio", "sfx_db", _sfx_volume_db), -30.0, 6.0)

	if _music_player:
		_music_player.volume_db = _music_volume_db


func _save_settings():
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "music_db", _music_volume_db)
	cfg.set_value("audio", "sfx_db", _sfx_volume_db)
	cfg.save(AUDIO_CONFIG_PATH)
