@tool
class_name MapElement extends Node

signal position_changed
signal link_changed

@export var links:Array[MapElement]:
	set(value):
		links = value
		link_changed.emit()

@export var position:Vector2i:
	set(value):
		if position != value:
			position = value
			position_changed.emit()

@export var preview_size:Vector2
@export var preview_texture:Texture2D
