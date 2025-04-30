class_name MapLink extends RefCounted

var A:Vector2i
var B:Vector2i

func _init(a:Vector2i,b:Vector2i) -> void:
	A = a
	B = b

func inverse() -> MapLink:
	return MapLink.new(B,A)
