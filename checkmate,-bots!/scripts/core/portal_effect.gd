extends Node2D
class_name PortalEffect

@export var portal_scale: float = 1.8

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
var _is_closing := false


func _ready():
	if sprite:
		sprite.scale = Vector2(portal_scale, portal_scale)
		sprite.play("open")
		if not sprite.animation_finished.is_connected(_on_animation_finished):
			sprite.animation_finished.connect(_on_animation_finished)


func close_and_free():
	if _is_closing:
		return

	_is_closing = true

	if sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation("close"):
		sprite.play("close")
	else:
		queue_free()


func _on_animation_finished():
	if not sprite:
		return

	if sprite.animation == "open":
		if sprite.sprite_frames.has_animation("loop"):
			sprite.play("loop")
	elif sprite.animation == "close":
		queue_free()
