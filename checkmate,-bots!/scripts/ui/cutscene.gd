extends Control
class_name Cutscene

@export var slides: Array[CutsceneSlide] = []
@export var next_scene_path: String = "res://scenes/main/world.tscn"
@export var fade_duration: float = 0.5

@onready var slide_container: Control = $SlideContainer
@onready var slide_text: RichTextLabel = $SlideContainer/VBoxContainer/SlideText
@onready var slide_image: TextureRect = $SlideContainer/VBoxContainer/SlideImage
@onready var progress_label: Label = $SlideContainer/VBoxContainer/ProgressLabel
@onready var continue_label: Label = $SlideContainer/ContinueLabel
@onready var skip_button: Button = $SkipButton
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var current_slide_index: int = 0
var can_advance: bool = true

func _ready():
	if slide_container:
		slide_container.modulate.a = 0.0
	
	if skip_button:
		skip_button.pressed.connect(_on_skip_pressed)
	
	_show_slide(0)
	
	# Play intro music if available
	if SoundManager:
		SoundManager.play_menu_music()

func _input(event: InputEvent):
	if not can_advance:
		return
	
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_SPACE or event.keycode == KEY_ENTER:
			_next_slide()
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_next_slide()

func _show_slide(index: int):
	if index < 0 or index >= slides.size():
		_end_cutscene()
		return
	
	current_slide_index = index
	var slide = slides[index]
	
	can_advance = false
	
	# Update slide content
	if slide_text:
		slide_text.text = slide.text
	
	if slide_image and slide.image:
		slide_image.texture = slide.image
		slide_image.visible = true
	elif slide_image:
		slide_image.visible = false
	
	# Update progress indicator
	if progress_label:
		progress_label.text = "%d / %d" % [index + 1, slides.size()]
	
	# Show continue prompt
	if continue_label:
		continue_label.visible = true
	
	# Fade in the slide
	_fade_in()

func _fade_in():
	if not animation_player:
		can_advance = true
		return
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	
	if slide_container:
		tween.tween_property(slide_container, "modulate:a", 1.0, fade_duration)
	
	await tween.finished
	can_advance = true

func _fade_out():
	can_advance = false
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	
	if slide_container:
		tween.tween_property(slide_container, "modulate:a", 0.0, fade_duration)
	
	await tween.finished

func _next_slide():
	if not can_advance:
		return
	
	if SoundManager:
		SoundManager.play_button_press()
	
	await _fade_out()
	
	if current_slide_index + 1 < slides.size():
		_show_slide(current_slide_index + 1)
	else:
		_end_cutscene()

func _on_skip_pressed():
	if SoundManager:
		SoundManager.play_button_press()
	_end_cutscene()

func _end_cutscene():
	await _fade_out()
	
	if SoundManager:
		SoundManager.play_game_music()
	
	get_tree().change_scene_to_file(next_scene_path)
