extends Resource
class_name CutsceneSlide

## A single slide in a cutscene sequence
## Contains text and optional image

@export_multiline var text: String = ""
@export var image: Texture2D
@export var background_color: Color = Color.BLACK
